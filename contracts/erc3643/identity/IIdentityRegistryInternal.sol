// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title Identity Registry Internal Interface
 * @notice Internal interface defining events, errors, and data structures for identity registry operations
 * @dev This interface contains events, errors, and structs used during identity management
 */
interface IIdentityRegistryInternal {
    /**
     * @notice Data structure holding identity information for a user
     * @param identity The address of the user's identity contract
     * @param country The country code representing the user's jurisdiction
     */
    struct IdentityData {
        address identity;
        uint16 country;
    }

    // Registry Events
    /**
     * @notice Emitted when the claim topics registry address is updated
     * @param claimTopicsRegistry The new claim topics registry address
     */
    event ClaimTopicsRegistrySet(address indexed claimTopicsRegistry);

    /**
     * @notice Emitted when the identity storage address is updated
     * @param identityStorage The new identity storage address
     */
    event IdentityStorageSet(address indexed identityStorage);

    /**
     * @notice Emitted when the trusted issuers registry address is updated
     * @param trustedIssuersRegistry The new trusted issuers registry address
     */
    event TrustedIssuersRegistrySet(address indexed trustedIssuersRegistry);

    /**
     * @notice Emitted when a new identity is registered for an investor
     * @param investorAddress The wallet address of the investor
     * @param identity The identity contract address that was registered
     */
    event IdentityRegistered(
        address indexed investorAddress,
        address indexed identity
    );

    /**
     * @notice Emitted when an identity registration is removed
     * @param investorAddress The wallet address of the investor
     * @param identity The identity contract address that was removed
     */
    event IdentityRemoved(
        address indexed investorAddress,
        address indexed identity
    );

    /**
     * @notice Emitted when an identity contract address is updated
     * @param oldIdentity The previous identity contract address
     * @param newIdentity The new identity contract address
     */
    event IdentityUpdated(
        address indexed oldIdentity,
        address indexed newIdentity
    );

    /**
     * @notice Emitted when a country code is updated for an investor
     * @param investorAddress The wallet address of the investor
     * @param country The new country code
     */
    event CountryUpdated(
        address indexed investorAddress,
        uint16 indexed country
    );

    // Storage Events
    /**
     * @notice Emitted when an identity is stored (storage-level event)
     * @param investorAddress The wallet address of the investor
     * @param identity The identity contract address that was stored
     */
    event IdentityStored(
        address indexed investorAddress,
        address indexed identity
    );

    /**
     * @notice Emitted when an identity is removed from storage (storage-level event)
     * @param investorAddress The wallet address of the investor
     * @param identity The identity contract address that was removed from storage
     */
    event IdentityUnstored(
        address indexed investorAddress,
        address indexed identity
    );

    /**
     * @notice Emitted when an identity is modified (storage-level event)
     * @param oldIdentity The previous identity contract address
     * @param newIdentity The new identity contract address
     */
    event IdentityModified(
        address indexed oldIdentity,
        address indexed newIdentity
    );

    /**
     * @notice Emitted when a country is modified (storage-level event)
     * @param investorAddress The wallet address of the investor
     * @param country The new country code
     */
    event CountryModified(
        address indexed investorAddress,
        uint16 indexed country
    );

    /**
     * @notice Emitted when an identity registry is bound
     * @param identityRegistry The identity registry address that was bound
     */
    event IdentityRegistryBound(address indexed identityRegistry);

    /**
     * @notice Emitted when an identity registry is unbound
     * @param identityRegistry The identity registry address that was unbound
     */
    event IdentityRegistryUnbound(address indexed identityRegistry);

    // Error definitions
    /**
     * @notice Error thrown when trying to register an identity that is already registered
     * @param investor The address that already has an identity registered
     */
    error IdentityAlreadyRegistered(address investor);

    /**
     * @notice Error thrown when trying to operate on an identity that is not registered
     * @param investor The address that does not have an identity registered
     */
    error IdentityNotRegistered(address investor);

    /**
     * @notice Error thrown when an invalid identity address is provided
     * @param identity The invalid identity address
     */
    error InvalidIdentityAddress(address identity);

    /**
     * @notice Error thrown when an invalid country code is provided
     * @param country The invalid country code
     */
    error InvalidCountryCode(uint16 country);
}
