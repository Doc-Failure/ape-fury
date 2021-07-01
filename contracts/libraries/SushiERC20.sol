// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.6.12;

import "../interfaces/IDAIPermit.sol";
import "../interfaces/IERC20.sol";

/// @title SushiERC20
/// @dev This library optimizes around ERC-20 token calls & safety checks - adapted from culinary excellence @boringcrypto/boring-solidity/contracts/libraries/BoringERC20.sol, License-Identifier: MIT.
library SushiERC20 {
    bytes4 private constant SIG_NAME = 0x06fdde03; // name()
    bytes4 private constant SIG_SYMBOL = 0x95d89b41; // symbol()
    bytes4 private constant SIG_DECIMALS = 0x313ce567; // decimals()
    bytes4 private constant SIG_BALANCE_OF = 0x70a08231; // balanceOf(address)
    bytes4 private constant SIG_APPROVE = 0x095ea7b3; // approve(address,uint256)
    bytes4 private constant SIG_TRANSFER = 0xa9059cbb; // transfer(address,uint256)
    bytes4 private constant SIG_TRANSFER_FROM = 0x23b872dd; // transferFrom(address,address,uint256)

    /// @dev Internal function to parse string data.
    function returnDataToString(bytes memory data) internal pure returns (string memory) {
        if (data.length >= 64) {
            return abi.decode(data, (string));
        } else if (data.length == 32) {
            uint8 i = 0;
            while(i < 32 && data[i] != 0) {
                i++;
            }
            bytes memory bytesArray = new bytes(i);
            for (i = 0; i < 32 && data[i] != 0; i++) {
                bytesArray[i] = data[i];
            }
            return string(bytesArray);
        } else {
            return "???";
        }
    }

    /// @notice Provides a safe ERC20.name version which returns '???' as fallback string.
    /// @param token The address of the ERC-20 token contract.
    /// @return (string) Token name.
    function safeName(IERC20 token) internal view returns (string memory) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_NAME));
        return success ? returnDataToString(data) : '???';
    }
    
    /// @notice Provides a safe ERC20.symbol version which returns '???' as fallback string.
    /// @param token The address of the ERC-20 token contract.
    /// @return (string) Token symbol.
    function safeSymbol(IERC20 token) internal view returns (string memory) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_SYMBOL));
        return success ? returnDataToString(data) : '???';
    }

    /// @notice Provides a safe ERC20.decimals version which returns '18' as fallback value.
    /// @param token The address of the ERC-20 token contract.
    /// @return (uint8) Token decimals.
    function safeDecimals(IERC20 token) internal view returns (uint8) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_DECIMALS));
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }
    
    /// @notice Provides a gas-optimized balance check to avoid a redundant extcodesize check in addition to the returndatasize check.
    /// @param token The address of the ERC-20 token.
    /// @param to The address of the user to check.
    /// @return amount The token amount.
    function safeBalanceOf(IERC20 token, address to) internal view returns (uint256 amount) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_BALANCE_OF, to));
        require(success && data.length >= 32, 'SushiERC20: BalanceOf failed');
        amount = abi.decode(data, (uint256));
    } 
    
    /// @notice Provides a gas-optimized balance check on this contract to avoid a redundant extcodesize check in addition to the returndatasize check.
    /// @param token The address of the ERC-20 token.
    /// @return amount The token amount.
    function safeBalanceOfSelf(IERC20 token) internal view returns (uint256 amount) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_BALANCE_OF, address(this)));
        require(success && data.length >= 32, 'SushiERC20: BalanceOf failed');
        amount = abi.decode(data, (uint256));
    }
    
    /// @notice Provides a safe ERC20.approve version for different ERC-20 implementations.
    /// @param token The address of the ERC-20 token.
    /// @param to The address of the user to grant spending right.
    /// @param amount The token amount to grant spending right over.
    function safeApprove(
        IERC20 token, 
        address to, 
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_APPROVE, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SushiERC20: Approve failed');
    }

    /// @notice Provides a safe ERC20.transfer version for different ERC-20 implementations.
    // Reverts on a failed transfer.
    /// @param token The address of the ERC-20 token.
    /// @param to Transfer tokens to.
    /// @param amount The token amount.
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SushiERC20: Transfer failed');
    }

    /// @notice Provides a safe ERC20.transferFrom version for different ERC-20 implementations.
    // Reverts on a failed transfer.
    /// @param token The address of the ERC-20 token.
    /// @param from Transfer tokens from.
    /// @param to Transfer tokens to.
    /// @param amount The token amount.
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER_FROM, from, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SushiERC20: TransferFrom failed');
    }

    /// @notice Provides an EIP-2612 signed approval for this contract to spend user tokens.
    /// @param token The address of the ERC-20 token.
    /// @param amount The token amount to grant spending right over.
    /// @param deadline Termination for signed approval (UTC timestamp in seconds).
    /// @param v Must produce valid secp256k1 signature from the owner along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the owner along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the owner along with `r` and `v`.
    function permitSelf(
        address token,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        IERC20(token).permit(msg.sender, address(this), amount, deadline, v, r, s);
    }
    
    /// @notice Provides a DAI-derived signed approval for this contract to spend user tokens.
    /// @param token The address of the ERC-20 token.
    /// @param nonce The owner's nonce (increases at each call to {permit}).
    /// @param expiry Termination for signed approval (UTC timestamp in seconds).
    /// @param v Must produce valid secp256k1 signature from the owner along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the owner along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the owner along with `r` and `v`.
    function permitSelfAllowed(
        address token,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        IDAIPermit(token).permit(msg.sender, address(this), nonce, expiry, true, v, r, s);
    }
}
