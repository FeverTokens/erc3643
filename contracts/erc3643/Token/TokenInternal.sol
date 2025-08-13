// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ITokenInternal.sol";
import "./TokenStorage.sol";
import "../../access/rbac/AccessControlInternal.sol";
import "../IdentityRegistry/IIdentityRegistry.sol";
import "../Compliance/ICompliance.sol";

abstract contract TokenInternal is ITokenInternal, AccessControlInternal {
    using TokenStorage for TokenStorage.Layout;
    
    bytes32 internal constant AGENT_ROLE = keccak256("AGENT_ROLE");
    bytes32 internal constant OWNER_ROLE = keccak256("OWNER_ROLE");
    
    // Virtual functions to emit ERC20 events - to be overridden by implementing contract
    function _emitTransfer(address from, address to, uint256 amount) internal virtual;
    function _emitApproval(address owner, address spender, uint256 amount) internal virtual;

    // Internal transfer function
    function _transfer(address _from, address _to, uint256 _amount) internal {
        TokenStorage.Layout storage l = TokenStorage.layout();
        
        if (_from == address(0) || _to == address(0)) {
            revert InvalidAddress(_from == address(0) ? _from : _to);
        }
        
        uint256 fromBalance = l.balances[_from];
        if (fromBalance < _amount) {
            revert InsufficientBalance(_amount, fromBalance);
        }
        
        l.balances[_from] = fromBalance - _amount;
        l.balances[_to] += _amount;
        
        _emitTransfer(_from, _to, _amount);
    }

    // Compliant transfer with checks
    function _transferWithCompliance(address _from, address _to, uint256 _amount) internal {
        TokenStorage.Layout storage l = TokenStorage.layout();
        
        // Check if paused
        if (l.paused) {
            revert TokenTransferWhilePaused();
        }
        
        // Check if wallets are frozen
        if (l.frozen[_from] || l.frozen[_to]) {
            revert WalletFrozen(l.frozen[_from] ? _from : _to);
        }
        
        // Check available balance (total - frozen tokens)
        uint256 availableBalance = l.balances[_from] - l.frozenTokens[_from];
        if (availableBalance < _amount) {
            revert InsufficientBalance(_amount, availableBalance);
        }
        
        // Check identity verification
        IIdentityRegistry registry = IIdentityRegistry(l.identityRegistry);
        if (!registry.isVerified(_to)) {
            revert IdentityNotVerified(_to);
        }
        
        // Check compliance
        ICompliance comp = ICompliance(l.compliance);
        if (!comp.canTransfer(_from, _to, _amount)) {
            revert ComplianceCheckFailed(_from, _to, _amount);
        }
        
        // Perform transfer
        _transfer(_from, _to, _amount);
        
        // Update compliance
        comp.transferred(_from, _to, _amount);
    }

    // Pause functions
    function _pause() internal onlyRole(AGENT_ROLE) {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal onlyRole(AGENT_ROLE) {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.paused = false;
        emit Unpaused(msg.sender);
    }

    // Freeze functions
    function _setAddressFrozen(address _userAddress, bool _freeze) internal onlyRole(AGENT_ROLE) {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.frozen[_userAddress] = _freeze;
        emit AddressFrozen(_userAddress, _freeze, msg.sender);
    }

    function _freezePartialTokens(address _userAddress, uint256 _amount) internal onlyRole(AGENT_ROLE) {
        TokenStorage.Layout storage l = TokenStorage.layout();
        
        uint256 balance = l.balances[_userAddress];
        require(balance >= l.frozenTokens[_userAddress] + _amount, "Cannot freeze more than balance");
        
        l.frozenTokens[_userAddress] += _amount;
        emit TokensFrozen(_userAddress, _amount);
    }

    function _unfreezePartialTokens(address _userAddress, uint256 _amount) internal onlyRole(AGENT_ROLE) {
        TokenStorage.Layout storage l = TokenStorage.layout();
        
        require(l.frozenTokens[_userAddress] >= _amount, "Cannot unfreeze more than frozen");
        
        l.frozenTokens[_userAddress] -= _amount;
        emit TokensUnfrozen(_userAddress, _amount);
    }

    // Mint and burn
    function _mint(address _to, uint256 _amount) internal onlyRole(AGENT_ROLE) {
        TokenStorage.Layout storage l = TokenStorage.layout();
        
        // Check identity verification
        IIdentityRegistry registry = IIdentityRegistry(l.identityRegistry);
        if (!registry.isVerified(_to)) {
            revert IdentityNotVerified(_to);
        }
        
        l.totalSupply += _amount;
        l.balances[_to] += _amount;
        
        // Update compliance
        ICompliance comp = ICompliance(l.compliance);
        comp.created(_to, _amount);
        
        _emitTransfer(address(0), _to, _amount);
    }

    function _burn(address _from, uint256 _amount) internal onlyRole(AGENT_ROLE) {
        TokenStorage.Layout storage l = TokenStorage.layout();
        
        uint256 balance = l.balances[_from];
        if (balance < _amount) {
            revert InsufficientBalance(_amount, balance);
        }
        
        l.balances[_from] = balance - _amount;
        l.totalSupply -= _amount;
        
        // Update compliance
        ICompliance comp = ICompliance(l.compliance);
        comp.destroyed(_from, _amount);
        
        _emitTransfer(_from, address(0), _amount);
    }

    // Forced transfer
    function _forcedTransfer(address _from, address _to, uint256 _amount) internal onlyRole(AGENT_ROLE) returns (bool) {
        TokenStorage.Layout storage l = TokenStorage.layout();
        
        // Check identity verification (bypass other compliance checks)
        IIdentityRegistry registry = IIdentityRegistry(l.identityRegistry);
        if (!registry.isVerified(_to)) {
            revert IdentityNotVerified(_to);
        }
        
        _transfer(_from, _to, _amount);
        
        // Update compliance
        ICompliance comp = ICompliance(l.compliance);
        comp.transferred(_from, _to, _amount);
        
        return true;
    }

    // Recovery
    function _recoveryAddress(
        address _lostWallet,
        address _newWallet,
        address _investorOnchainID
    ) internal onlyRole(AGENT_ROLE) returns (bool) {
        TokenStorage.Layout storage l = TokenStorage.layout();
        
        // Check identity verification for new wallet
        IIdentityRegistry registry = IIdentityRegistry(l.identityRegistry);
        if (!registry.isVerified(_newWallet)) {
            revert IdentityNotVerified(_newWallet);
        }
        
        uint256 balance = l.balances[_lostWallet];
        if (balance > 0) {
            l.balances[_lostWallet] = 0;
            l.balances[_newWallet] = balance;
            
            // Update compliance
            ICompliance comp = ICompliance(l.compliance);
            comp.transferred(_lostWallet, _newWallet, balance);
        }
        
        // Store recovery history
        l.recoveries[_lostWallet] = _newWallet;
        
        emit RecoverySuccess(_lostWallet, _newWallet, _investorOnchainID);
        return true;
    }

    // Registry setters
    function _setIdentityRegistry(address _identityRegistryAddr) internal onlyRole(OWNER_ROLE) {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.identityRegistry = _identityRegistryAddr;
        emit IdentityRegistryAdded(_identityRegistryAddr);
    }

    function _setCompliance(address _complianceAddr) internal onlyRole(OWNER_ROLE) {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.compliance = _complianceAddr;
        emit ComplianceAdded(_complianceAddr);
    }

    // Metadata setters
    function _setName(string calldata _nameStr) internal onlyRole(OWNER_ROLE) {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.name = _nameStr;
    }

    function _setSymbol(string calldata _symbolStr) internal onlyRole(OWNER_ROLE) {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.symbol = _symbolStr;
    }

    function _setOnchainID(address _onchainIDAddr) internal onlyRole(OWNER_ROLE) {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.onchainID = _onchainIDAddr;
        emit UpdatedTokenInformation(l.name, l.symbol, l.decimals, l.version, _onchainIDAddr);
    }

    // ERC20 internal functions
    function _approve(address _owner, address _spender, uint256 _amount) internal {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.allowances[_owner][_spender] = _amount;
        _emitApproval(_owner, _spender, _amount);
    }

    // View functions
    function _paused() internal view returns (bool) {
        return TokenStorage.layout().paused;
    }

    function _isFrozen(address _userAddress) internal view returns (bool) {
        return TokenStorage.layout().frozen[_userAddress];
    }

    function _getFrozenTokens(address _userAddress) internal view returns (uint256) {
        return TokenStorage.layout().frozenTokens[_userAddress];
    }

    function _identityRegistry() internal view returns (address) {
        return TokenStorage.layout().identityRegistry;
    }

    function _compliance() internal view returns (address) {
        return TokenStorage.layout().compliance;
    }

    function _onchainID() internal view returns (address) {
        return TokenStorage.layout().onchainID;
    }

    function _version() internal view returns (string memory) {
        return TokenStorage.layout().version;
    }

    function _name() internal view returns (string memory) {
        return TokenStorage.layout().name;
    }

    function _symbol() internal view returns (string memory) {
        return TokenStorage.layout().symbol;
    }

    function _decimals() internal view returns (uint8) {
        return TokenStorage.layout().decimals;
    }

    function _totalSupply() internal view returns (uint256) {
        return TokenStorage.layout().totalSupply;
    }

    function _balanceOf(address _account) internal view returns (uint256) {
        return TokenStorage.layout().balances[_account];
    }

    function _allowance(address _owner, address _spender) internal view returns (uint256) {
        return TokenStorage.layout().allowances[_owner][_spender];
    }

    // ERC20 transfer functions
    function _transfer(address _to, uint256 _amount) internal returns (bool) {
        _transferWithCompliance(msg.sender, _to, _amount);
        return true;
    }

    function _transferFrom(address _from, address _to, uint256 _amount) internal returns (bool) {
        TokenStorage.Layout storage l = TokenStorage.layout();
        
        uint256 currentAllowance = l.allowances[_from][msg.sender];
        if (currentAllowance < _amount) {
            revert InsufficientBalance(_amount, currentAllowance);
        }
        
        _transferWithCompliance(_from, _to, _amount);
        
        if (currentAllowance != type(uint256).max) {
            _approve(_from, msg.sender, currentAllowance - _amount);
        }
        
        return true;
    }

    // Batch functions
    function _batchTransfer(
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) internal {
        require(_toList.length == _amounts.length, "Array length mismatch");
        
        for (uint256 i = 0; i < _toList.length; i++) {
            _transferWithCompliance(msg.sender, _toList[i], _amounts[i]);
        }
    }

    function _batchForcedTransfer(
        address[] calldata _fromList,
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) internal {
        require(_fromList.length == _toList.length && _fromList.length == _amounts.length, "Array length mismatch");
        
        for (uint256 i = 0; i < _fromList.length; i++) {
            _forcedTransfer(_fromList[i], _toList[i], _amounts[i]);
        }
    }

    function _batchMint(
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) internal {
        require(_toList.length == _amounts.length, "Array length mismatch");
        
        for (uint256 i = 0; i < _toList.length; i++) {
            _mint(_toList[i], _amounts[i]);
        }
    }

    function _batchBurn(
        address[] calldata _userAddresses,
        uint256[] calldata _amounts
    ) internal {
        require(_userAddresses.length == _amounts.length, "Array length mismatch");
        
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            _burn(_userAddresses[i], _amounts[i]);
        }
    }

    function _batchSetAddressFrozen(
        address[] calldata _userAddresses,
        bool[] calldata _freeze
    ) internal {
        require(_userAddresses.length == _freeze.length, "Array length mismatch");
        
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            _setAddressFrozen(_userAddresses[i], _freeze[i]);
        }
    }

    function _batchFreezePartialTokens(
        address[] calldata _userAddresses,
        uint256[] calldata _amounts
    ) internal {
        require(_userAddresses.length == _amounts.length, "Array length mismatch");
        
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            _freezePartialTokens(_userAddresses[i], _amounts[i]);
        }
    }

    function _batchUnfreezePartialTokens(
        address[] calldata _userAddresses,
        uint256[] calldata _amounts
    ) internal {
        require(_userAddresses.length == _amounts.length, "Array length mismatch");
        
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            _unfreezePartialTokens(_userAddresses[i], _amounts[i]);
        }
    }
}