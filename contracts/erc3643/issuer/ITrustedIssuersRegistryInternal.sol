// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title Trusted Issuers Registry Internal Interface
 * @notice Internal interface defining events, errors, and data structures for trusted issuer registry operations
 * @dev This interface contains events, errors, and structs used during trusted issuer management
 */
interface ITrustedIssuersRegistryInternal {
    /**
     * @notice Data structure holding trusted issuer information
     * @param exists Boolean indicating if the issuer is currently trusted
     * @param claimTopics Array of claim topic IDs that this issuer can verify
     */
    struct TrustedIssuer {
        bool exists;
        uint256[] claimTopics;
    }

    /**
     * @notice Emitted when a new trusted issuer is added
     * @param trustedIssuer The address of the issuer that was added as trusted
     * @param claimTopics Array of claim topic IDs assigned to this issuer
     */
    event TrustedIssuerAdded(address indexed trustedIssuer, uint256[] claimTopics);
    
    /**
     * @notice Emitted when a trusted issuer is removed
     * @param trustedIssuer The address of the issuer that was removed
     */
    event TrustedIssuerRemoved(address indexed trustedIssuer);
    
    /**
     * @notice Emitted when claim topics are updated for a trusted issuer
     * @param trustedIssuer The address of the issuer whose claim topics were updated
     * @param claimTopics New array of claim topic IDs for this issuer
     */
    event ClaimTopicsUpdated(address indexed trustedIssuer, uint256[] claimTopics);

    /**
     * @notice Error thrown when trying to add an issuer that is already trusted
     * @param issuer The address that is already a trusted issuer
     */
    error IssuerAlreadyTrusted(address issuer);
    
    /**
     * @notice Error thrown when trying to operate on an issuer that is not trusted
     * @param issuer The address that is not a trusted issuer
     */
    error IssuerNotTrusted(address issuer);
    
    /**
     * @notice Error thrown when trying to add an issuer with no claim topics
     */
    error EmptyClaimTopics();
    
    /**
     * @notice Error thrown when an invalid issuer address is provided
     * @param issuer The invalid issuer address
     */
    error InvalidIssuerAddress(address issuer);
}