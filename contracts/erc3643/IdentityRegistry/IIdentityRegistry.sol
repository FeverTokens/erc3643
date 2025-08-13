// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IIdentityRegistryInternal.sol";

// Note: ERC3643 specification uses specific interface types, but for package compatibility we use address
// In a full ERC3643 implementation: issuersRegistry() returns ITrustedIssuersRegistry, 
// topicsRegistry() returns IClaimTopicsRegistry, identity() returns IIdentity
interface IIdentityRegistry is IIdentityRegistryInternal {
    // Identity registry getters
    function issuersRegistry() external view returns (address);
    function topicsRegistry() external view returns (address);

    // Identity registry setters
    function setClaimTopicsRegistry(address _claimTopicsRegistry) external;
    function setTrustedIssuersRegistry(address _trustedIssuersRegistry) external;

    // Registry actions
    function registerIdentity(address _userAddress, address _identity, uint16 _country) external;
    function deleteIdentity(address _userAddress) external;
    function updateCountry(address _userAddress, uint16 _country) external;
    function updateIdentity(address _userAddress, address _identity) external;
    function batchRegisterIdentity(
        address[] calldata _userAddresses,
        address[] calldata _identities,
        uint16[] calldata _countries
    ) external;

    // Registry consultation
    function contains(address _userAddress) external view returns (bool);
    function isVerified(address _userAddress) external view returns (bool);
    function identity(address _userAddress) external view returns (address);
    function investorCountry(address _userAddress) external view returns (uint16);
    
    // Storage management (merged from IdentityRegistryStorage)
    function storedIdentity(address _userAddress) external view returns (address);
    function storedInvestorCountry(address _userAddress) external view returns (uint16);
}