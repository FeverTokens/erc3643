// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ITokenManagementInternal.sol";

interface ITokenManagement is ITokenManagementInternal {
    // Freezes a specified amount of tokens for a user
    function freezeTokens(address user, uint256 amount) external;

    // Unfreezes a specified amount of tokens for a user
    function unfreezeTokens(address user, uint256 amount) external;
}
