// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import '../interfaces/IERC20.sol';
import '../interfaces/IDAIPermit.sol';

// File @boringcrypto/boring-solidity/contracts/BoringBatchable.sol@v1.2.0
// License-Identifier: MIT
contract BaseBoringBatchable {
    /// @dev Helper function to extract a useful revert message from a failed call.
    // If the returned data is malformed or not correctly abi encoded then this call can fail itself.
    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (_returnData.length < 68) return "Transaction reverted silently";

        assembly {
            // Slice the sighash.
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }

    /// @notice Allows batched call to self (this contract).
    /// @param calls An array of inputs for each call.
    /// @param revertOnFail If True then reverts after a failed call and stops doing further calls.
    function batch(bytes[] calldata calls, bool revertOnFail) external payable {
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(calls[i]);
            if (!success && revertOnFail) {
                revert(_getRevertMsg(result));
            }
        }
    }
}

/// @dev Extends `BoringBatchable` with DAI-derived {permit}.
contract BoringBatchableWithDai is BaseBoringBatchable {
    /// @notice Call wrapper that performs `ERC20.permit` using DAI-derived EIP-2612 primitive.
    function permitDai(
        IDAIPermit token,
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        token.permit(holder, spender, nonce, expiry, true, v, r, s);
    }
    
    /// @notice Call wrapper that performs EIP-2612 `ERC20.permit` on `token`.
    function permitToken(
        IERC20 token,
        address from,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        token.permit(from, to, amount, deadline, v, r, s);
    }
}
