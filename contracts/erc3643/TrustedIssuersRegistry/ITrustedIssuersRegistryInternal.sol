// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ITrustedIssuersRegistryInternal {
    // Structs
    struct TrustedIssuer {
        bool exists;
        uint256[] claimTopics;
    }

    // Events
    event TrustedIssuerAdded(address indexed trustedIssuer, uint256[] claimTopics);
    event TrustedIssuerRemoved(address indexed trustedIssuer);
    event ClaimTopicsUpdated(address indexed trustedIssuer, uint256[] claimTopics);

    // Errors
    error IssuerAlreadyTrusted(address issuer);
    error IssuerNotTrusted(address issuer);
    error EmptyClaimTopics();
    error InvalidIssuerAddress(address issuer);
}