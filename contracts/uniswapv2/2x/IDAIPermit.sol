// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.7.6;

/// @title IDAIPermit
/// @notice This interface composes DAI-derived {permit}.
interface IDAIPermit {
    /// @dev DAI-derived {permit}.
    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
