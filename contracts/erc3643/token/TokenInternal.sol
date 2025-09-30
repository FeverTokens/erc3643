// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ITokenInternal.sol";
import "./TokenStorage.sol";
import "../../token/ERC20/base/IERC20BaseInternal.sol";
import "../agent/AgentRoleInternal.sol";
import "../compliance/ICompliance.sol";
import "../compliance/ComplianceInternal.sol";
import "../identity/IIdentityRegistry.sol";
import "../identity/IdentityRegistryInternal.sol";

abstract contract TokenInternal is
    ITokenInternal,
    IERC20BaseInternal,
    AgentRoleInternal,
    IdentityRegistryInternal,
    ComplianceInternal
{
    using TokenStorage for TokenStorage.Layout;

    string internal constant TOKEN_VERSION = "1.0.0";

    function __TokenInternal_init(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) internal {
        __TokenInternal_init_unchained(name, symbol, decimals);
    }

    function __TokenInternal_init_unchained(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) internal {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.name = name;
        l.symbol = symbol;
        l.decimals = decimals;
    }

    // Internal transfer function - overrides ERC20BaseInternal
    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
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

        emit Transfer(_from, _to, _amount);
        return true;
    }

    // Compliant transfer with checks
    function _transferWithCompliance(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
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
        if (!_isVerified(_to)) {
            revert IdentityNotVerified(_to);
        }

        // Check compliance
        if (!_canTransfer(_from, _to, _amount)) {
            revert ComplianceCheckFailed(_from, _to, _amount);
        }

        // Perform transfer
        _transfer(_from, _to, _amount);

        // Update compliance
        _transferred(_from, _to, _amount);
    }

    // Pause functions
    function _pause() internal onlyAgent {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal onlyAgent {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.paused = false;
        emit Unpaused(msg.sender);
    }

    // Freeze functions
    function _setAddressFrozen(
        address _userAddress,
        bool _freeze
    ) internal onlyAgent {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.frozen[_userAddress] = _freeze;
        emit AddressFrozen(_userAddress, _freeze, msg.sender);
    }

    function _freezePartialTokens(
        address _userAddress,
        uint256 _amount
    ) internal onlyAgent {
        TokenStorage.Layout storage l = TokenStorage.layout();

        uint256 balance = l.balances[_userAddress];
        require(
            balance >= l.frozenTokens[_userAddress] + _amount,
            "Cannot freeze more than balance"
        );

        l.frozenTokens[_userAddress] += _amount;
        emit TokensFrozen(_userAddress, _amount);
    }

    function _unfreezePartialTokens(
        address _userAddress,
        uint256 _amount
    ) internal onlyAgent {
        TokenStorage.Layout storage l = TokenStorage.layout();

        require(
            l.frozenTokens[_userAddress] >= _amount,
            "Cannot unfreeze more than frozen"
        );

        l.frozenTokens[_userAddress] -= _amount;
        emit TokensUnfrozen(_userAddress, _amount);
    }

    // Mint and burn - overrides ERC20BaseInternal
    function _mint(address _to, uint256 _amount) internal onlyAgent {
        TokenStorage.Layout storage l = TokenStorage.layout();

        // Check identity verification
        if (!_isVerified(_to)) {
            revert IdentityNotVerified(_to);
        }

        l.totalSupply += _amount;
        l.balances[_to] += _amount;

        // Update compliance
        _created(_to, _amount);

        emit Transfer(address(0), _to, _amount);
    }

    function _burn(address _from, uint256 _amount) internal onlyAgent {
        TokenStorage.Layout storage l = TokenStorage.layout();

        uint256 balance = l.balances[_from];
        if (balance < _amount) {
            revert InsufficientBalance(_amount, balance);
        }

        l.balances[_from] = balance - _amount;
        l.totalSupply -= _amount;

        // Update compliance
        _destroyed(_from, _amount);

        emit Transfer(_from, address(0), _amount);
    }

    // Forced transfer
    function _forcedTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal onlyAgent returns (bool) {
        // Check identity verification (bypass other compliance checks)
        if (!_isVerified(_to)) {
            revert IdentityNotVerified(_to);
        }

        _transfer(_from, _to, _amount);

        // Update compliance
        _transferred(_from, _to, _amount);

        return true;
    }

    // Recovery
    function _recoveryAddress(
        address _lostWallet,
        address _newWallet,
        address _investorOnchainID
    ) internal onlyAgent returns (bool) {
        TokenStorage.Layout storage l = TokenStorage.layout();

        // Check identity verification for new wallet
        if (!_isVerified(_newWallet)) {
            revert IdentityNotVerified(_newWallet);
        }

        uint256 balance = l.balances[_lostWallet];
        if (balance > 0) {
            l.balances[_lostWallet] = 0;
            l.balances[_newWallet] = balance;

            // Update compliance
            _transferred(_lostWallet, _newWallet, balance);
        }

        // Store recovery history
        l.recoveries[_lostWallet] = _newWallet;

        emit RecoverySuccess(_lostWallet, _newWallet, _investorOnchainID);
        return true;
    }

    // Registry setters
    function _setIdentityRegistry(
        address _identityRegistryAddr
    ) internal onlyOwner {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.identityRegistry = _identityRegistryAddr;
        emit IdentityRegistryAdded(_identityRegistryAddr);
    }

    function _setCompliance(address _complianceAddr) internal onlyOwner {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.compliance = _complianceAddr;
        emit ComplianceAdded(_complianceAddr);
    }

    // Metadata setters
    function _setName(string calldata _nameStr) internal onlyOwner {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.name = _nameStr;
    }

    function _setSymbol(string calldata _symbolStr) internal onlyOwner {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.symbol = _symbolStr;
    }

    function _setOnchainID(address _onchainIDAddr) internal onlyOwner {
        TokenStorage.Layout storage l = TokenStorage.layout();
        l.onchainID = _onchainIDAddr;
        emit UpdatedTokenInformation(
            l.name,
            l.symbol,
            l.decimals,
            TOKEN_VERSION,
            _onchainIDAddr
        );
    }

    // ERC20 internal functions - overrides ERC20BaseInternal
    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal returns (bool) {
        if (_owner == address(0))
            revert("ERC20Base: Approve From Zero Address");
        if (_spender == address(0))
            revert("ERC20Base: Approve To Zero Address");

        TokenStorage.Layout storage l = TokenStorage.layout();
        l.allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
        return true;
    }

    // View functions
    function _paused() internal view returns (bool) {
        return TokenStorage.layout().paused;
    }

    function _isFrozen(address _userAddress) internal view returns (bool) {
        return TokenStorage.layout().frozen[_userAddress];
    }

    function _getFrozenTokens(
        address _userAddress
    ) internal view returns (uint256) {
        return TokenStorage.layout().frozenTokens[_userAddress];
    }

    function _identityRegistry() internal view returns (IIdentityRegistry) {
        return IIdentityRegistry(TokenStorage.layout().identityRegistry);
    }

    function _compliance() internal view returns (ICompliance) {
        return ICompliance(TokenStorage.layout().compliance);
    }

    function _onchainID() internal view returns (address) {
        return TokenStorage.layout().onchainID;
    }

    function _version() internal pure returns (string memory) {
        return TOKEN_VERSION;
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

    function _allowance(
        address _owner,
        address _spender
    ) internal view returns (uint256) {
        return TokenStorage.layout().allowances[_owner][_spender];
    }

    // ERC20 transfer functions
    function _transferERC20(
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        _transferWithCompliance(msg.sender, _to, _amount);
        return true;
    }

    function _transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        TokenStorage.Layout storage l = TokenStorage.layout();

        // Agents can transfer without prior allowance; others must have allowance
        bool callerIsAgent = _isAgent(msg.sender);

        uint256 currentAllowance = l.allowances[_from][msg.sender];
        if (!callerIsAgent && currentAllowance < _amount) {
            revert InsufficientBalance(_amount, currentAllowance);
        }

        _transferWithCompliance(_from, _to, _amount);

        // Only decrease allowance for non-agent callers
        if (!callerIsAgent && currentAllowance != type(uint256).max) {
            l.allowances[_from][msg.sender] = currentAllowance - _amount;
            emit Approval(_from, msg.sender, currentAllowance - _amount);
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
        require(
            _fromList.length == _toList.length &&
                _fromList.length == _amounts.length,
            "Array length mismatch"
        );

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
        require(
            _userAddresses.length == _amounts.length,
            "Array length mismatch"
        );

        for (uint256 i = 0; i < _userAddresses.length; i++) {
            _burn(_userAddresses[i], _amounts[i]);
        }
    }

    function _batchSetAddressFrozen(
        address[] calldata _userAddresses,
        bool[] calldata _freeze
    ) internal {
        require(
            _userAddresses.length == _freeze.length,
            "Array length mismatch"
        );

        for (uint256 i = 0; i < _userAddresses.length; i++) {
            _setAddressFrozen(_userAddresses[i], _freeze[i]);
        }
    }

    function _batchFreezePartialTokens(
        address[] calldata _userAddresses,
        uint256[] calldata _amounts
    ) internal {
        require(
            _userAddresses.length == _amounts.length,
            "Array length mismatch"
        );

        for (uint256 i = 0; i < _userAddresses.length; i++) {
            _freezePartialTokens(_userAddresses[i], _amounts[i]);
        }
    }

    function _batchUnfreezePartialTokens(
        address[] calldata _userAddresses,
        uint256[] calldata _amounts
    ) internal {
        require(
            _userAddresses.length == _amounts.length,
            "Array length mismatch"
        );

        for (uint256 i = 0; i < _userAddresses.length; i++) {
            _unfreezePartialTokens(_userAddresses[i], _amounts[i]);
        }
    }
}
