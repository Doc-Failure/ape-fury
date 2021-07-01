// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
    
    function safeBalanceOf(IERC20 token, address to) internal view returns (uint256 amount) {
        // bytes4(keccak256(bytes('balanceOf(address)')));
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x70a08231, to));
        require(success && data.length >= 32, 'TransferHelper: BALANCE_FAILED');
        amount = abi.decode(data, (uint256));
    } 
    
    function safeBalanceOfSelf(IERC20 token) internal view returns (uint256 amount) {
        // bytes4(keccak256(bytes('balanceOf(address)')));
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x70a08231, address(this)));
        require(success && data.length >= 32, 'TransferHelper: BALANCE_FAILED');
        amount = abi.decode(data, (uint256));
    }
}
