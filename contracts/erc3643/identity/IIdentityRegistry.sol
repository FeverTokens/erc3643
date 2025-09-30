// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IIdentityRegistryInternal.sol";
import "../IIdentityRegistryStorage.sol";
import "../issuer/ITrustedIssuersRegistry.sol";
import "../claim/IClaimTopicsRegistry.sol";

/**
 * @title Identity Registry Interface
 * @notice External interface for managing identity verification and registration in the ERC3643 ecosystem
 * @dev This interface extends IIdentityRegistryInternal and provides external functions for identity management
 * @dev Uses address types for compatibility, in full ERC3643: IIdentity, ITrustedIssuersRegistry, IClaimTopicsRegistry
 */
interface IIdentityRegistry is IIdentityRegistryInternal {
    // Registry Getters
    /**
     * @notice Returns the address of the identity storage contract
     * @return The identity storage contract address
     */
    function identityStorage() external view returns (IIdentityRegistryStorage);

    /**
     * @notice Returns the address of the trusted issuers registry
     * @return The trusted issuers registry contract
     */
    function issuersRegistry() external view returns (ITrustedIssuersRegistry);

    /**
     * @notice Returns the address of the claim topics registry
     * @return The claim topics registry contract
     */
    function topicsRegistry() external view returns (IClaimTopicsRegistry);

    // Registry Setters
    /**
     * @notice Sets the identity registry storage address
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _identityRegistryStorage The new identity registry storage contract address
     */
    function setIdentityRegistryStorage(
        address _identityRegistryStorage
    ) external;

    /**
     * @notice Sets the claim topics registry address
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _claimTopicsRegistry The new claim topics registry contract address
     */
    function setClaimTopicsRegistry(address _claimTopicsRegistry) external;

    /**
     * @notice Sets the trusted issuers registry address
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _trustedIssuersRegistry The new trusted issuers registry contract address
     */
    function setTrustedIssuersRegistry(
        address _trustedIssuersRegistry
    ) external;

    // Registry Actions
    /**
     * @notice Registers a new identity for a user address
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _userAddress The wallet address of the user
     * @param _identity The identity contract for the user
     * @param _country The country code for the user's jurisdiction
     */
    function registerIdentity(
        address _userAddress,
        IIdentity _identity,
        uint16 _country
    ) external;

    /**
     * @notice Removes an identity registration for a user address
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _userAddress The wallet address to deregister
     */
    function deleteIdentity(address _userAddress) external;

    /**
     * @notice Updates the country code for a registered user
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _userAddress The wallet address to update
     * @param _country The new country code
     */
    function updateCountry(address _userAddress, uint16 _country) external;

    /**
     * @notice Updates the identity contract address for a registered user
     * @dev Only addresses with AGENT_ROLE can call this function
     * @param _userAddress The wallet address to update
     * @param _identity The new identity contract
     */
    function updateIdentity(address _userAddress, IIdentity _identity) external;

    /**
     * @notice Registers multiple identities in a single transaction
     * @dev Only addresses with AGENT_ROLE can call this function. All arrays must have equal length.
     * @param _userAddresses Array of wallet addresses to register
     * @param _identities Array of identity contracts
     * @param _countries Array of country codes
     */
    function batchRegisterIdentity(
        address[] calldata _userAddresses,
        IIdentity[] calldata _identities,
        uint16[] calldata _countries
    ) external;

    // Registry Consultation
    /**
     * @notice Checks if a user address has a registered identity
     * @param _userAddress The wallet address to check
     * @return bool True if the address has a registered identity, false otherwise
     */
    function contains(address _userAddress) external view returns (bool);

    /**
     * @notice Checks if a user address is verified (simple whitelist implementation)
     * @param _userAddress The wallet address to check
     * @return bool True if the address is verified, false otherwise
     */
    function isVerified(address _userAddress) external view returns (bool);

    /**
     * @notice Returns the identity contract address for a registered user
     * @param _userAddress The wallet address to query
     * @return The identity contract, or zero address if not registered
     */
    function identity(address _userAddress) external view returns (IIdentity);

    /**
     * @notice Returns the country code for a registered user
     * @param _userAddress The wallet address to query
     * @return uint16 The country code, or 0 if not registered
     */
    function investorCountry(
        address _userAddress
    ) external view returns (uint16);

    // Storage Functions
    /**
     * @notice Returns the stored identity contract address for a user
     * @param _userAddress The wallet address to query
     * @return The stored identity contract
     */
    function storedIdentity(
        address _userAddress
    ) external view returns (IIdentity);

    /**
     * @notice Returns the stored country code for a user
     * @param _userAddress The wallet address to query
     * @return The stored country code
     */
    function storedInvestorCountry(
        address _userAddress
    ) external view returns (uint16);

    /**
     * @notice Adds an identity to storage
     * @dev Only bound identity registries can call this function
     * @param _userAddress The wallet address of the user
     * @param _identity The identity contract to store
     * @param _country The country code
     */
    function addIdentityToStorage(
        address _userAddress,
        IIdentity _identity,
        uint16 _country
    ) external;

    /**
     * @notice Removes an identity from storage
     * @dev Only bound identity registries can call this function
     * @param _userAddress The wallet address to remove
     */
    function removeIdentityFromStorage(address _userAddress) external;

    /**
     * @notice Modifies the stored country for a user
     * @dev Only bound identity registries can call this function
     * @param _userAddress The wallet address to update
     * @param _country The new country code
     */
    function modifyStoredInvestorCountry(
        address _userAddress,
        uint16 _country
    ) external;

    /**
     * @notice Modifies the stored identity for a user
     * @dev Only bound identity registries can call this function
     * @param _userAddress The wallet address to update
     * @param _identity The new identity contract
     */
    function modifyStoredIdentity(
        address _userAddress,
        IIdentity _identity
    ) external;

    // Registry Binding
    /**
     * @notice Binds an identity registry to this storage
     * @dev Only the contract owner can call this function
     * @param _identityRegistry The identity registry address to bind
     */
    function bindIdentityRegistry(address _identityRegistry) external;

    /**
     * @notice Unbinds an identity registry from this storage
     * @dev Only the contract owner can call this function
     * @param _identityRegistry The identity registry address to unbind
     */
    function unbindIdentityRegistry(address _identityRegistry) external;

    /**
     * @notice Returns all linked identity registries
     * @return address[] Array of bound identity registry addresses
     */
    function linkedIdentityRegistries()
        external
        view
        returns (address[] memory);
}
