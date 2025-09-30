// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IIdentityRegistry.sol";
import "./IdentityRegistryInternal.sol";

contract IdentityRegistry is IIdentityRegistry, IdentityRegistryInternal {
    // Registry Getters
    function identityStorage()
        external
        view
        override
        returns (IIdentityRegistryStorage)
    {
        return _identityStorage();
    }

    function issuersRegistry()
        external
        view
        override
        returns (ITrustedIssuersRegistry)
    {
        return _issuersRegistry();
    }

    function topicsRegistry()
        external
        view
        override
        returns (IClaimTopicsRegistry)
    {
        return _topicsRegistry();
    }

    // Registry Setters
    function setIdentityRegistryStorage(
        address _identityRegistryStorage
    ) external override {
        _setIdentityRegistryStorage(_identityRegistryStorage);
    }

    function setClaimTopicsRegistry(
        address _claimTopicsRegistry
    ) external override {
        _setClaimTopicsRegistry(_claimTopicsRegistry);
    }

    function setTrustedIssuersRegistry(
        address _trustedIssuersRegistry
    ) external override {
        _setTrustedIssuersRegistry(_trustedIssuersRegistry);
    }

    // Registry Actions
    function registerIdentity(
        address _userAddress,
        IIdentity _identity,
        uint16 _country
    ) external override {
        _registerIdentity(_userAddress, _identity, _country);
    }

    function deleteIdentity(address _userAddress) external override {
        _deleteIdentity(_userAddress);
    }

    function updateCountry(
        address _userAddress,
        uint16 _country
    ) external override {
        _updateCountry(_userAddress, _country);
    }

    function updateIdentity(
        address _userAddress,
        IIdentity _identity
    ) external override {
        _updateIdentity(_userAddress, _identity);
    }

    function batchRegisterIdentity(
        address[] calldata _userAddresses,
        IIdentity[] calldata _identities,
        uint16[] calldata _countries
    ) external override {
        _batchRegisterIdentity(_userAddresses, _identities, _countries);
    }

    // Registry Consultation
    function contains(
        address _userAddress
    ) external view override returns (bool) {
        return _contains(_userAddress);
    }

    function isVerified(
        address _userAddress
    ) external view override returns (bool) {
        return _isVerified(_userAddress);
    }

    function identity(
        address _userAddress
    ) external view override returns (IIdentity) {
        return _identity(_userAddress);
    }

    function investorCountry(
        address _userAddress
    ) external view override returns (uint16) {
        return _investorCountry(_userAddress);
    }

    // Storage Functions
    function storedIdentity(
        address _userAddress
    ) external view override returns (IIdentity) {
        return _storedIdentity(_userAddress);
    }

    function storedInvestorCountry(
        address _userAddress
    ) external view override returns (uint16) {
        return _storedInvestorCountry(_userAddress);
    }

    function addIdentityToStorage(
        address _userAddress,
        IIdentity _identity,
        uint16 _country
    ) external override {
        _addIdentityToStorage(_userAddress, _identity, _country);
    }

    function removeIdentityFromStorage(address _userAddress) external override {
        _removeIdentityFromStorage(_userAddress);
    }

    function modifyStoredInvestorCountry(
        address _userAddress,
        uint16 _country
    ) external override {
        _modifyStoredInvestorCountry(_userAddress, _country);
    }

    function modifyStoredIdentity(
        address _userAddress,
        IIdentity _identity
    ) external override {
        _modifyStoredIdentity(_userAddress, _identity);
    }

    // Registry Binding
    function bindIdentityRegistry(address _identityRegistry) external override {
        _bindIdentityRegistry(_identityRegistry);
    }

    function unbindIdentityRegistry(
        address _identityRegistry
    ) external override {
        _unbindIdentityRegistry(_identityRegistry);
    }

    function linkedIdentityRegistries()
        external
        view
        override
        returns (address[] memory)
    {
        return _linkedIdentityRegistries();
    }
}
