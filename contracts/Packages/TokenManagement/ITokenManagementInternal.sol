// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
pragma experimental ABIEncoderV2;

interface ITokenManagementInternal {
    //Events
    event TokensFrozen(address indexed user, uint256 amount);

    event TokensUnfrozen(address indexed user, uint256 amount);

    event TokenPaused(bool paused);
}
