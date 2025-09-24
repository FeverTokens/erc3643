// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../token/ERC20/IERC20.sol";
import "./IERC3643Internal.sol";

/**
 * @title ERC3643 Compliant Token Interface
 * @notice Interface for ERC3643 compliant tokens with identity verification and compliance features
 * @dev This interface extends IERC20 and adds identity registry, compliance, and freezing functionality
 * @dev ERC3643 is a standard for permissioned tokens on Ethereum with built-in compliance
 */
interface IERC3643 is IERC3643Internal, IERC20 {
    /**
     * @notice Returns the address of the token's onchain identity
     * @return address The onchain identity contract address
     */
    function onchainID() external view returns (address);

    /**
     * @notice Returns the version string of the token contract
     * @return string The version identifier
     */
    function version() external view returns (string memory);

    /**
     * @notice Returns the address of the identity registry
     * @return address The identity registry contract address
     */
    function identityRegistry() external view returns (address);

    /**
     * @notice Returns the address of the compliance contract
     * @return address The compliance contract address
     */
    function compliance() external view returns (address);

    /**
     * @notice Returns whether the token contract is paused
     * @return bool True if paused, false otherwise
     */
    function paused() external view returns (bool);

    /**
     * @notice Returns whether a specific address is frozen
     * @param _userAddress The address to check
     * @return bool True if the address is frozen, false otherwise
     */
    function isFrozen(address _userAddress) external view returns (bool);

    /**
     * @notice Returns the amount of frozen tokens for a specific address
     * @param _userAddress The address to check
     * @return uint256 The amount of frozen tokens
     */
    function getFrozenTokens(
        address _userAddress
    ) external view returns (uint256);

    /**
     * @notice Sets the token name
     * @dev Only the contract owner can call this function
     * @param _name The new token name
     */
    function setName(string calldata _name) external;

    /**
     * @notice Sets the token symbol
     * @dev Only the contract owner can call this function
     * @param _symbol The new token symbol
     */
    function setSymbol(string calldata _symbol) external;

    /**
     * @notice Sets the onchain identity address
     * @dev Only the contract owner can call this function
     * @param _onchainID The new onchain identity contract address
     */
    function setOnchainID(address _onchainID) external;

    /**
     * @notice Pauses all token transfers
     * @dev Only addresses with AGENT_ROLE can call this function
     */
    function pause() external;

    /**
     * @notice Unpauses token transfers
     * @dev Only addresses with AGENT_ROLE can call this function
     */
    function unpause() external;

    /**
     * @notice Freezes or unfreezes a specific address
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _userAddress The address to freeze/unfreeze
     * @param _freeze True to freeze, false to unfreeze
     */
    function setAddressFrozen(address _userAddress, bool _freeze) external;

    /**
     * @notice Freezes a partial amount of tokens for a specific address
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _userAddress The address whose tokens to freeze
     * @param _amount The amount of tokens to freeze
     */
    function freezePartialTokens(
        address _userAddress,
        uint256 _amount
    ) external;

    /**
     * @notice Unfreezes a partial amount of tokens for a specific address
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _userAddress The address whose tokens to unfreeze
     * @param _amount The amount of tokens to unfreeze
     */
    function unfreezePartialTokens(
        address _userAddress,
        uint256 _amount
    ) external;

    /**
     * @notice Sets the identity registry address
     * @dev Only the contract owner can call this function
     * @param _identityRegistry The new identity registry contract address
     */
    function setIdentityRegistry(address _identityRegistry) external;

    /**
     * @notice Sets the compliance contract address
     * @dev Only the contract owner can call this function
     * @param _compliance The new compliance contract address
     */
    function setCompliance(address _compliance) external;

    /**
     * @notice Executes a forced transfer bypassing normal compliance checks
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _from The address to transfer from
     * @param _to The address to transfer to
     * @param _amount The amount to transfer
     * @return bool True if the transfer succeeded
     */
    function forcedTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool);

    /**
     * @notice Mints new tokens to a specific address
     * @dev Only addresses with AGENT_ROLE can call this function. Recipient must be identity verified.
     * @param _to The address to mint tokens to
     * @param _amount The amount of tokens to mint
     */
    function mint(address _to, uint256 _amount) external;

    /**
     * @notice Burns tokens from a specific address
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _userAddress The address to burn tokens from
     * @param _amount The amount of tokens to burn
     */
    function burn(address _userAddress, uint256 _amount) external;

    /**
     * @notice Recovers tokens from a lost wallet to a new wallet
     * @dev Only addresses with AGENT_ROLE can call this function. Used for wallet recovery scenarios.
     * @param _lostWallet The address of the lost/compromised wallet
     * @param _newWallet The address of the new wallet
     * @param _investorOnchainID The onchain identity of the investor
     * @return bool True if the recovery succeeded
     */
    function recoveryAddress(
        address _lostWallet,
        address _newWallet,
        address _investorOnchainID
    ) external returns (bool);

    /**
     * @notice Transfers tokens to multiple addresses in a single transaction
     * @param _toList Array of recipient addresses
     * @param _amounts Array of amounts to transfer (must match _toList length)
     */
    function batchTransfer(
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) external;

    /**
     * @notice Executes multiple forced transfers in a single transaction
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _fromList Array of sender addresses
     * @param _toList Array of recipient addresses
     * @param _amounts Array of amounts to transfer (all arrays must have equal length)
     */
    function batchForcedTransfer(
        address[] calldata _fromList,
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) external;

    /**
     * @notice Mints tokens to multiple addresses in a single transaction
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _toList Array of recipient addresses
     * @param _amounts Array of amounts to mint (must match _toList length)
     */
    function batchMint(
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) external;

    /**
     * @notice Burns tokens from multiple addresses in a single transaction
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _userAddresses Array of addresses to burn tokens from
     * @param _amounts Array of amounts to burn (must match _userAddresses length)
     */
    function batchBurn(
        address[] calldata _userAddresses,
        uint256[] calldata _amounts
    ) external;

    /**
     * @notice Freezes or unfreezes multiple addresses in a single transaction
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _userAddresses Array of addresses to freeze/unfreeze
     * @param _freeze Array of freeze flags (must match _userAddresses length)
     */
    function batchSetAddressFrozen(
        address[] calldata _userAddresses,
        bool[] calldata _freeze
    ) external;

    /**
     * @notice Freezes partial tokens for multiple addresses in a single transaction
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _userAddresses Array of addresses whose tokens to freeze
     * @param _amounts Array of amounts to freeze (must match _userAddresses length)
     */
    function batchFreezePartialTokens(
        address[] calldata _userAddresses,
        uint256[] calldata _amounts
    ) external;

    /**
     * @notice Unfreezes partial tokens for multiple addresses in a single transaction
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _userAddresses Array of addresses whose tokens to unfreeze
     * @param _amounts Array of amounts to unfreeze (must match _userAddresses length)
     */
    function batchUnfreezePartialTokens(
        address[] calldata _userAddresses,
        uint256[] calldata _amounts
    ) external;
}
