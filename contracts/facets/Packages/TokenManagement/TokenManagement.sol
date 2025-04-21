// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./ITokenManagement.sol";
import "./TokenManagementInternal.sol";

contract TokenManagement is ITokenManagement, TokenManagementInternal {
    function mintERC3643(address _to, uint256 _amount) external override {
        _mintERC3643(_to, _amount);
    }

    function burnERC3643(
        address _userAddress,
        uint256 _amount
    ) external override {
        _burnERC3643(_userAddress, _amount);
    }

    function freezeTokens(address user, uint256 amount) external override {
        _freezeTokens(user, amount);
    }

    function unfreezeTokens(address user, uint256 amount) external override {
        _unfreezeTokens(user, amount);
    }

    function freezeWallet(address user) external override {
        _freezeWallet(user);
    }

    function unfreezeWallet(address user) external override {
        _unfreezeWallet(user);
    }

    function batchMintTokens(
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) external override {
        _batchMintTokens(_toList, _amounts);
    }

    function batchBurnTokens(
        address[] calldata _fromList,
        uint256[] calldata _amounts
    ) external override {
        _batchBurnTokens(_fromList, _amounts);
    }
}
