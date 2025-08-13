// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IIdentityRegistry.sol";
import "./IdentityRegistryInternal.sol";

contract IdentityRegistry is IIdentityRegistry, IdentityRegistryInternal {
    
    // Identity registry getters
    function issuersRegistry() external view override returns (address) {
        return _issuersRegistry();
    }
    
    function topicsRegistry() external view override returns (address) {
        return _topicsRegistry();
    }

    // Identity registry setters
    function setClaimTopicsRegistry(address _claimTopicsRegistry) external override {
        _setClaimTopicsRegistry(_claimTopicsRegistry);
    }
    
    function setTrustedIssuersRegistry(address _trustedIssuersRegistry) external override {
        _setTrustedIssuersRegistry(_trustedIssuersRegistry);
    }

    // Registry actions
    function registerIdentity(address _userAddress, address _identity, uint16 _country) external override {
        _registerIdentity(_userAddress, _identity, _country);
    }
    
    function deleteIdentity(address _userAddress) external override {
        _deleteIdentity(_userAddress);
    }
    
    function updateCountry(address _userAddress, uint16 _country) external override {
        _updateCountry(_userAddress, _country);
    }
    
    function updateIdentity(address _userAddress, address _identity) external override {
        _updateIdentity(_userAddress, _identity);
    }
    
    function batchRegisterIdentity(
        address[] calldata _userAddresses,
        address[] calldata _identities,
        uint16[] calldata _countries
    ) external override {
        _batchRegisterIdentity(_userAddresses, _identities, _countries);
    }

    // Registry consultation
    function contains(address _userAddress) external view override returns (bool) {
        return _contains(_userAddress);
    }
    
    function isVerified(address _userAddress) external view override returns (bool) {
        return _isVerified(_userAddress);
    }
    
    function identity(address _userAddress) external view override returns (address) {
        return _identity(_userAddress);
    }
    
    function investorCountry(address _userAddress) external view override returns (uint16) {
        return _investorCountry(_userAddress);
    }
    
    // Storage management (merged from IdentityRegistryStorage)
    function storedIdentity(address _userAddress) external view override returns (address) {
        return _identity(_userAddress);
    }
    
    function storedInvestorCountry(address _userAddress) external view override returns (uint16) {
        return _investorCountry(_userAddress);
    }
}