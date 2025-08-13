// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ITokenInternal {
    // Events
    event UpdatedTokenInformation(
        string _newName,
        string _newSymbol,
        uint8 _newDecimals,
        string _newVersion,
        address _newOnchainID
    );
    event IdentityRegistryAdded(address indexed _identityRegistry);
    event ComplianceAdded(address indexed _compliance);
    event RecoverySuccess(
        address _lostWallet,
        address _newWallet,
        address _investorOnchainID
    );
    event AddressFrozen(
        address indexed _userAddress,
        bool indexed _isFrozen,
        address indexed _owner
    );
    event TokensFrozen(address indexed _userAddress, uint256 _amount);
    event TokensUnfrozen(address indexed _userAddress, uint256 _amount);
    event Paused(address _userAddress);
    event Unpaused(address _userAddress);

    // Errors
    error TokenTransferWhilePaused();
    error WalletFrozen(address wallet);
    error InsufficientBalance(uint256 requested, uint256 available);
    error IdentityNotVerified(address identity);
    error ComplianceCheckFailed(address from, address to, uint256 amount);
    error InvalidAddress(address addr);
    error InvalidAmount(uint256 amount);
}