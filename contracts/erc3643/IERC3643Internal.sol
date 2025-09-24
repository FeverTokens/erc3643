// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title ERC3643 Internal Interface
 * @notice Internal interface defining events and errors for ERC3643 token operations
 * @dev This interface contains events and errors emitted during token operations
 */
interface IERC3643Internal {
    /**
     * @notice Emitted when token information is updated
     * @param _newName The new token name
     * @param _newSymbol The new token symbol
     * @param _newDecimals The new decimal places (typically immutable)
     * @param _newVersion The new version string
     * @param _newOnchainID The new onchain identity address
     */
    event UpdatedTokenInformation(
        string _newName,
        string _newSymbol,
        uint8 _newDecimals,
        string _newVersion,
        address _newOnchainID
    );

    /**
     * @notice Emitted when the identity registry is set or updated
     * @param _identityRegistry The new identity registry address
     */
    event IdentityRegistryAdded(address indexed _identityRegistry);

    /**
     * @notice Emitted when the compliance contract is set or updated
     * @param _compliance The new compliance contract address
     */
    event ComplianceAdded(address indexed _compliance);

    /**
     * @notice Emitted when a wallet recovery is successfully completed
     * @param _lostWallet The address of the lost/compromised wallet
     * @param _newWallet The address of the new wallet
     * @param _investorOnchainID The onchain identity of the investor
     */
    event RecoverySuccess(
        address _lostWallet,
        address _newWallet,
        address _investorOnchainID
    );

    /**
     * @notice Emitted when an address is frozen or unfrozen
     * @param _userAddress The address that was frozen/unfrozen
     * @param _isFrozen True if frozen, false if unfrozen
     * @param _owner The address that performed the freeze operation
     */
    event AddressFrozen(
        address indexed _userAddress,
        bool indexed _isFrozen,
        address indexed _owner
    );

    /**
     * @notice Emitted when a partial amount of tokens is frozen for an address
     * @param _userAddress The address whose tokens were frozen
     * @param _amount The amount of tokens that were frozen
     */
    event TokensFrozen(address indexed _userAddress, uint256 _amount);

    /**
     * @notice Emitted when a partial amount of tokens is unfrozen for an address
     * @param _userAddress The address whose tokens were unfrozen
     * @param _amount The amount of tokens that were unfrozen
     */
    event TokensUnfrozen(address indexed _userAddress, uint256 _amount);

    /**
     * @notice Emitted when the token contract is paused
     * @param _userAddress The address that paused the contract
     */
    event Paused(address _userAddress);

    /**
     * @notice Emitted when the token contract is unpaused
     * @param _userAddress The address that unpaused the contract
     */
    event Unpaused(address _userAddress);

    /**
     * @notice Error thrown when attempting to transfer tokens while the contract is paused
     */
    error TokenTransferWhilePaused();

    /**
     * @notice Error thrown when attempting to transfer from/to a frozen wallet
     * @param wallet The address of the frozen wallet
     */
    error WalletFrozen(address wallet);

    /**
     * @notice Error thrown when attempting to transfer more tokens than available
     * @param requested The amount requested for transfer
     * @param available The amount available for transfer
     */
    error InsufficientBalance(uint256 requested, uint256 available);

    /**
     * @notice Error thrown when attempting to transfer to an unverified identity
     * @param identity The address that failed identity verification
     */
    error IdentityNotVerified(address identity);

    /**
     * @notice Error thrown when an invalid address is provided
     * @param addr The invalid address
     */
    error InvalidAddress(address addr);

    /**
     * @notice Error thrown when an invalid amount is provided
     * @param amount The invalid amount
     */
    error InvalidAmount(uint256 amount);
}
