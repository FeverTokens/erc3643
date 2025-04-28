// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ITokenOperation.sol";
import "./TokenOperationInternal.sol";

contract TokenOperation is ITokenOperation, TokenOperationInternal {
    function init__ERC20Metadata(
        string calldata __name,
        string calldata __symbol,
        uint8 __decimals
    ) external {
        _init_ERC20Metadata(__name, __symbol, __decimals);
    }

    function name() external view returns (string memory) {
        return _name();
    }

    function symbol() external view returns (string memory) {
        return _symbol();
    }

    function decimals() external view returns (uint8) {
        return _decimals();
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply();
    }

    function totalStaked() external view returns (uint256) {
        return _totalStaked();
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balanceOf(account);
    }

    function stakedBalance(address account) external view returns (uint256) {
        return _stakedBalance(account);
    }

    function canTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (bool) {
        return _canTransfer(_from, _to, _amount);
    }

    function transferERC3643Token(
        address _to,
        uint256 _amount
    ) external override returns (bool status) {
        return _transferERC3643(msg.sender, _to, _amount);
    }

    function getBalance(address _userAddress) external view returns (uint256) {
        return _getBalance(_userAddress);
    }

    function forcedTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external override {
        _forcedTransfer(_from, _to, _amount);
    }

    function batchTransfer(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external override returns (bool) {
        return _batchTransfer(recipients, amounts);
    }

    // recovery-related functions such as recovering tokens and tokens from contracts.
    function recoverTokens(
        address lostWallet,
        address newWallet,
        uint256 amount
    ) external override {
        _recoverTokens(lostWallet, newWallet, amount);
    }

    function recoverTokensFromContract(
        address token,
        uint256 amount
    ) external override {
        _recoverTokensFromContract(token, amount);
    }

    // staking-related functions such as staking and unstaking tokens.
    function stake(uint256 amount) external override returns (uint256) {
        return _stake(amount);
    }

    function unstake(uint256 amount) external override returns (uint256) {
        return _unstake(amount);
    }

    // swap-related functions such as selling and swapping tokens.
    function sellTokens(uint256 amount) external override {
        _sellTokens(amount);
    }

    function swapTokens(address token, uint256 amount) external override {
        _swapTokens(token, amount);
    }

    function batchUpdateFrozenStatus(
        address[] calldata _addresses,
        bool[] calldata _statuses
    ) external override {
        _batchUpdateFrozenStatus(_addresses, _statuses);
    }

    function freezeWallet(address user) external override {
        _freezeWallet(user);
    }

    function unfreezeWallet(address user) external override {
        _unfreezeWallet(user);
    }

    function mintERC3643(address _to, uint256 _amount) external override {
        _mintERC3643(_to, _amount);
    }

    function burnERC3643(
        address _userAddress,
        uint256 _amount
    ) external override {
        _burnERC3643(_userAddress, _amount);
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
