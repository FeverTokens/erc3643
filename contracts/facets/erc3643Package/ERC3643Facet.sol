// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./IERC3643.sol";
import "./ERC3643Internal.sol";

 contract ERC3643Facet is IERC3643, ERC3643Internal {
    function addAgent(address _agent) external override {
        _addAgent(_agent);
    }

    function removeAgent(address _agent) external override {
        _removeAgent(_agent);
    }

    function isAgent(address _agent) external view override returns (bool) {
        return _isAgent(_agent);
    }

    function isVerified(address _userAddress) external view override returns (bool) {
        return _verifyIdentity(_userAddress);
    }

    function canTransfer(address _from, address _to, uint256 _amount) external view returns (bool) {
        return _canTransfer(_from, _to, _amount);
    }

    function transferERC3643Token(address _to, uint256 _amount) external override {
        _transferERC3643(msg.sender, _to, _amount);   
    }

    function forcedTransfer(address _from, address _to, uint256 _amount) external override {
        _forcedTransfer(_from, _to, _amount);
    }

    function getBalance(address _userAddress) external view returns (uint256) {
        return _getBalance(_userAddress);
    }
    
    function mintERC3643(address _to, uint256 _amount) external override {
        _mintERC3643(_to, _amount);
    }

    function burnERC3643(address _userAddress, uint256 _amount) external override {
        _burnERC3643(_userAddress, _amount);
    }

    // // Implement other external functions as required by the ERC-3643 standard
    function freezeTokens(address user, uint256 amount) external override {
        _freezeTokens(user, amount);
    }

    function unfreezeTokens(address user, uint256 amount) external override {
        _unfreezeTokens(user, amount);
    }

    function freezeWallet(address user) external override {
        _freezeWallet(user);
    }

    function unfreezeWallet(address user) external override{
        _unfreezeWallet(user);
    }

    function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external {
        _batchTransfer(recipients, amounts);
    }

    function recoverTokens(address lostWallet, address newWallet, uint256 amount) external override{
        _recoverTokens(lostWallet, newWallet, amount);
    }
    
    function recoverTokensFromContract(address token, uint256 amount) external override {
        _recoverTokensFromContract(token, amount);
    }

    function stake(uint256 amount) external override {
        _stake(amount);
    }

    function unstake(uint256 amount) external override {
        _unstake(amount);
    }

    function sellTokens(uint256 amount) external override{
        _sellTokens(amount);
    }

    function swapTokens(address token, uint256 amount) external override {
        _swapTokens(token, amount);
    }

}