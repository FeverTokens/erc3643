// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IIdentityRegistryInternal {
    // Structs
    struct IdentityData {
        address identity;
        uint16 country;
    }

    // Events
    event ClaimTopicsRegistrySet(address indexed claimTopicsRegistry);
    event TrustedIssuersRegistrySet(address indexed trustedIssuersRegistry);
    event IdentityRegistered(address indexed investorAddress, address indexed identity);
    event IdentityRemoved(address indexed investorAddress, address indexed identity);
    event IdentityUpdated(address indexed oldIdentity, address indexed newIdentity);
    event CountryUpdated(address indexed investorAddress, uint16 indexed country);
    event IdentityStored(address indexed investorAddress, address indexed identity);
    event IdentityUnstored(address indexed investorAddress, address indexed identity);
    event IdentityModified(address indexed oldIdentity, address indexed newIdentity);
    event CountryModified(address indexed investorAddress, uint16 indexed country);

    // Errors
    error IdentityAlreadyRegistered(address investor);
    error IdentityNotRegistered(address investor);
    error InvalidIdentityAddress(address identity);
    error InvalidCountryCode(uint16 country);
}