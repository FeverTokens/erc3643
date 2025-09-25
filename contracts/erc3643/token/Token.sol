// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IToken.sol";
import "./TokenInternal.sol";

contract Token is TokenInternal, IToken {
    // ERC20Metadata functions
    function name() external view returns (string memory) {
        return _name();
    }

    function symbol() external view returns (string memory) {
        return _symbol();
    }

    function decimals() external view returns (uint8) {
        return _decimals();
    }

    // ERC20 functions
    function totalSupply() external view returns (uint256) {
        return _totalSupply();
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balanceOf(account);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        return _transferERC20(to, amount);
    }

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        return _allowance(owner, spender);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        return _transferFrom(from, to, amount);
    }

    // ERC3643 getters
    function onchainID() external view returns (address) {
        return _onchainID();
    }

    function version() external pure returns (string memory) {
        return _version();
    }

    function identityRegistry() external view returns (address) {
        return _identityRegistry();
    }

    function compliance() external view returns (address) {
        return _compliance();
    }

    function paused() external view returns (bool) {
        return _paused();
    }

    function isFrozen(address _userAddress) external view returns (bool) {
        return _isFrozen(_userAddress);
    }

    function getFrozenTokens(
        address _userAddress
    ) external view returns (uint256) {
        return _getFrozenTokens(_userAddress);
    }

    // ERC3643 setters
    function setName(string calldata _name_) external {
        _setName(_name_);
    }

    function setSymbol(string calldata _symbol_) external {
        _setSymbol(_symbol_);
    }

    function setOnchainID(address _onchainID_) external {
        _setOnchainID(_onchainID_);
    }

    function pause() external {
        _pause();
    }

    function unpause() external {
        _unpause();
    }

    function setAddressFrozen(address _userAddress, bool _freeze) external {
        _setAddressFrozen(_userAddress, _freeze);
    }

    function freezePartialTokens(
        address _userAddress,
        uint256 _amount
    ) external {
        _freezePartialTokens(_userAddress, _amount);
    }

    function unfreezePartialTokens(
        address _userAddress,
        uint256 _amount
    ) external {
        _unfreezePartialTokens(_userAddress, _amount);
    }

    function setIdentityRegistry(address _identityRegistry_) external {
        _setIdentityRegistry(_identityRegistry_);
    }

    function setCompliance(address _compliance_) external {
        _setCompliance(_compliance_);
    }

    function forcedTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool) {
        return _forcedTransfer(_from, _to, _amount);
    }

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }

    function burn(address _userAddress, uint256 _amount) external {
        _burn(_userAddress, _amount);
    }

    function recoveryAddress(
        address _lostWallet,
        address _newWallet,
        address _investorOnchainID
    ) external returns (bool) {
        return _recoveryAddress(_lostWallet, _newWallet, _investorOnchainID);
    }

    // Batch functions
    function batchTransfer(
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) external {
        _batchTransfer(_toList, _amounts);
    }

    function batchForcedTransfer(
        address[] calldata _fromList,
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) external {
        _batchForcedTransfer(_fromList, _toList, _amounts);
    }

    function batchMint(
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) external {
        _batchMint(_toList, _amounts);
    }

    function batchBurn(
        address[] calldata _userAddresses,
        uint256[] calldata _amounts
    ) external {
        _batchBurn(_userAddresses, _amounts);
    }

    function batchSetAddressFrozen(
        address[] calldata _userAddresses,
        bool[] calldata _freeze
    ) external {
        _batchSetAddressFrozen(_userAddresses, _freeze);
    }

    function batchFreezePartialTokens(
        address[] calldata _userAddresses,
        uint256[] calldata _amounts
    ) external {
        _batchFreezePartialTokens(_userAddresses, _amounts);
    }

    function batchUnfreezePartialTokens(
        address[] calldata _userAddresses,
        uint256[] calldata _amounts
    ) external {
        _batchUnfreezePartialTokens(_userAddresses, _amounts);
    }
}
