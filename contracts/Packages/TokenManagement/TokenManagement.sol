// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ITokenManagement.sol";
import "./TokenManagementInternal.sol";

contract TokenManagement is ITokenManagement, TokenManagementInternal {
    function freezeTokens(address user, uint256 amount) external override {
        _freezeTokens(user, amount);
    }

    function unfreezeTokens(address user, uint256 amount) external override {
        _unfreezeTokens(user, amount);
    }

    function setTokenPaused(bool _paused) external {
        _setTokenPaused(_paused);
    }
}
