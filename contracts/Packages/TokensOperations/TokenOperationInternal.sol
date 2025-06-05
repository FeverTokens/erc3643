// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ITokenOperationInternal.sol";
import "./TokenOperationStorage.sol";
import "../AgentManagement/AgentManagementInternal.sol";
import "../ComplianceAndOnChainIdTokenManagement/ComplianceOnChainIdInternal.sol";
import "../TokenManagement/TokenManagementInternal.sol";
import "../../access/rbac/AccessControlInternal.sol";


abstract contract TokenOperationInternal is
    ITokenOperationInternal,
    AccessControlInternal,
    AgentManagementInternal,
    ComplianceOnChainIdInternal,
    TokenManagementInternal
{
    modifier customInitializer(bytes32 storageSlot_) {
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();

        if (
            l.initialization[storageSlot_] != InitializationStatus.UnInitialized
        ) {
            revert InitializableInvalidInitialization();
        }

        l.initialization[storageSlot_] = InitializationStatus.Initializing;

        _;

        l.initialization[storageSlot_] = InitializationStatus.Initialized;

        emit Initialized(storageSlot_);
    }

    function _init_ERC20Metadata(
        string calldata name_,
        string calldata symbol_,
        uint8 decimals_
    ) internal {
        _init_ERC20MetadataInternal(name_, symbol_, decimals_);
    }

    function _init_ERC20MetadataInternal(
        string calldata name_,
        string calldata symbol_,
        uint8 decimals_
    ) internal customInitializer(TokenOperationStorage.STORAGE_SLOT) {
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();

        l.name = name_;
        l.symbol = symbol_;
        l.decimals = decimals_;
    }

    function _name() internal view returns (string memory) {
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        return l.name;
    }

    function _symbol() internal view returns (string memory) {
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        return l.symbol;
    }

    function _decimals() internal view returns (uint8) {
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        return l.decimals;
    }

    function _totalSupply() internal view returns (uint256) {
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        return l.totalSupply;
    }

    function _totalStaked() internal view returns (uint256) {
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        return l.totalStaked;
    }

    function _balanceOf(address account) internal view returns (uint256) {
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        return l.balances[account];
    }

    function _stakedBalance(address account) internal view returns (uint256) {
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        return l.stakedBalances[account];
    }

    function _canTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal view returns (bool) {
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();

        // Check if the sender has enough balance
        if (l.balances[_from] < _amount) {
            return false;
        }

        // Check if the receiver is not a frozen address
        if (l.walletFrozen[_to]) {
            return false;
        }

        return true;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        require(l.balances[_from] >= _amount, "Insufficient balance");
        l.balances[_from] -= _amount;
        l.balances[_to] += _amount;
        emit TransferERC3643(_from, _to, _amount);
        return true;
    }

    // transfer tokens after checking
    function _transferERC3643(
        address _from,
        address _to,
        uint256 _amount
    ) internal whenNotPaused returns (bool status) {
        //check if the transfer is possible
        require(_canTransfer(_from, _to, _amount), "we can't transfer");

        //check if the transfer compliant
        require(_isTransferCompliant(_from, _to), "Transfer is not Compliant");

        //proceed the transfer
        return _transfer(_from, _to, _amount);
    }

    //force transfer without checking by agents only
    function _forcedTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal onlyRole(AGENT_ROLE) returns (bool status) {    
        //proceed the transfer without checking
        return _transfer(_from, _to, _amount);
    }

    function _batchTransfer(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) internal returns (bool) {
        // This could involve looping through recipients and amounts and calling _transfer
        require(
            recipients.length == amounts.length,
            "Mismatched recipients and amounts"
        );
        for (uint256 i = 0; i < recipients.length; i++) {
            bool success = _forcedTransfer(
                msg.sender,
                recipients[i],
                amounts[i]
            );
            require(success, "individual transfer failed");
        }
        return true;
    }

    function _mintERC3643(address _to, uint256 _amount) internal {
        // This could involve updating the total supply and the balance of the recipient
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        l.totalSupply += _amount;
        l.balances[_to] += _amount;
        emit TransferERC3643(address(0), _to, _amount);
    }

    function _burnERC3643(address _userAddress, uint256 _amount) internal {
        // This could involve updating the total supply and the balance of the user
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        require(l.balances[_userAddress] >= _amount, "Insufficient balance");
        l.totalSupply -= _amount;
        l.balances[_userAddress] -= _amount;
        emit TransferERC3643(_userAddress, address(0), _amount);
    }

    function _batchMintTokens(
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) internal {
        require(
            _toList.length == _amounts.length,
            "Mismatched recipients and amounts"
        );
        for (uint256 i = 0; i < _toList.length; i++) {
            _mintERC3643(_toList[i], _amounts[i]);
        }
    }

    function _batchBurnTokens(
        address[] calldata _fromList,
        uint256[] calldata _amounts
    ) internal {
        require(
            _fromList.length == _amounts.length,
            "Mismatched senders and amounts"
        );
        for (uint256 i = 0; i < _fromList.length; i++) {
            _burnERC3643(_fromList[i], _amounts[i]);
        }
    }

    function _getBalance(address _userAddress) internal view returns (uint256) {
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        return l.balances[_userAddress];
    }

    //by agent only
    function _recoverTokens(
        address lostWallet,
        address newWallet,
        uint256 amount
    ) internal {
        // Implement logic for token recovery
        // This could involve transferring tokens from a lost wallet to a new wallet
        _forcedTransfer(lostWallet, newWallet, amount);
    }

    //by agent only
    function _recoverTokensFromContract(
        address token,
        uint256 amount
    ) internal {
        // Implement logic for token recovery
        // This could involve transferring tokens from a contract to the owner
        _forcedTransfer(token, msg.sender, amount);
    }

    function _stake(uint256 amount) internal returns (uint256) {
        // Implement logic for staking tokens
        // This could involve updating the staked balance and total staked
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        require(l.balances[msg.sender] >= amount, "Insufficient balance");
        l.balances[msg.sender] -= amount;
        l.stakedBalances[msg.sender] += amount;
        l.totalStaked += amount;

        return l.stakedBalances[msg.sender];
    }

    function _unstake(uint256 amount) internal returns (uint256) {
        // Implement logic for unstaking tokens
        // This could involve updating the staked balance and total staked
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        require(
            l.stakedBalances[msg.sender] >= amount,
            "Insufficient staked balance"
        );
        l.stakedBalances[msg.sender] -= amount;
        l.balances[msg.sender] += amount;
        l.totalStaked -= amount;

        return l.stakedBalances[msg.sender];
    }

    function _sellTokens(uint256 amount) internal {
        // Implement logic for selling tokens
        // This could involve transferring tokens from the owner to the contract
        _forcedTransfer(msg.sender, address(this), amount);
    }

    function _swapTokens(address token, uint256 amount) internal {
        // Implement logic for swapping tokens
        // This could involve transferring tokens from the user to the contract
        _forcedTransfer(msg.sender, token, amount);
    }

    function _batchUpdateFrozenStatus(
        address[] calldata _addresses,
        bool[] calldata _statuses
    ) internal {
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        require(
            _addresses.length == _statuses.length,
            "Mismatched addresses and statuses"
        );
        for (uint256 i = 0; i < _addresses.length; i++) {
            l.walletFrozen[_addresses[i]] = _statuses[i];
            emit WalletFrozenStatusUpdated(_addresses[i], _statuses[i]);
        }
    }

    function _freezeWallet(address user) internal onlyRole(AGENT_ROLE) {   
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        l.walletFrozen[user] = true;
        emit WalletFrozen(user);
    }

    function _unfreezeWallet(address user) internal onlyRole(AGENT_ROLE)  {    
        TokenOperationStorage.Layout storage l = TokenOperationStorage.layout();
        l.walletFrozen[user] = false;
        emit WalletUnfrozen(user);
    }
}
