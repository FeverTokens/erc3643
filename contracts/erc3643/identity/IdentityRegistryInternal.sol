// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IIdentityRegistryInternal.sol";
import "./IdentityRegistryStorage.sol";
import "../IIdentity.sol";
import "../IIdentityRegistryStorage.sol";
import "../claim/IClaimTopicsRegistry.sol";
import "../issuer/ITrustedIssuersRegistry.sol";
import "../agent/AgentRoleInternal.sol";

abstract contract IdentityRegistryInternal is
    IIdentityRegistryInternal,
    AgentRoleInternal
{
    using IdentityRegistryStorage for IdentityRegistryStorage.Layout;

    function _setClaimTopicsRegistry(
        address _claimTopicsRegistry
    ) internal onlyAgent {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();
        l.claimTopicsRegistry = _claimTopicsRegistry;
        emit ClaimTopicsRegistrySet(_claimTopicsRegistry);
    }

    function _setTrustedIssuersRegistry(
        address _trustedIssuersRegistry
    ) internal onlyAgent {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();
        l.trustedIssuersRegistry = _trustedIssuersRegistry;
        emit TrustedIssuersRegistrySet(_trustedIssuersRegistry);
    }

    function _registerIdentity(
        address _userAddress,
        IIdentity _identityContract,
        uint16 _country
    ) internal onlyAgent {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();

        if (l.identityExists[_userAddress]) {
            revert IdentityAlreadyRegistered(_userAddress);
        }
        address identityAddr = address(_identityContract);
        if (identityAddr == address(0)) {
            revert InvalidIdentityAddress(identityAddr);
        }

        l.identities[_userAddress] = IdentityData({
            identity: identityAddr,
            country: _country
        });
        l.identityExists[_userAddress] = true;

        emit IdentityRegistered(_userAddress, _identityContract);
        emit IdentityStored(_userAddress, _identityContract);
    }

    function _deleteIdentity(address _userAddress) internal onlyAgent {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();

        if (!l.identityExists[_userAddress]) {
            revert IdentityNotRegistered(_userAddress);
        }

        IIdentity oldIdentity = IIdentity(l.identities[_userAddress].identity);
        delete l.identities[_userAddress];
        l.identityExists[_userAddress] = false;

        emit IdentityRemoved(_userAddress, oldIdentity);
        emit IdentityUnstored(_userAddress, oldIdentity);
    }

    function _updateCountry(
        address _userAddress,
        uint16 _country
    ) internal onlyAgent {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();

        if (!l.identityExists[_userAddress]) {
            revert IdentityNotRegistered(_userAddress);
        }

        l.identities[_userAddress].country = _country;

        emit CountryUpdated(_userAddress, _country);
        emit CountryModified(_userAddress, _country);
    }

    function _updateIdentity(
        address _userAddress,
        IIdentity _identityContract
    ) internal onlyAgent {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();

        if (!l.identityExists[_userAddress]) {
            revert IdentityNotRegistered(_userAddress);
        }
        address identityAddr = address(_identityContract);
        if (identityAddr == address(0)) {
            revert InvalidIdentityAddress(identityAddr);
        }

        IIdentity oldIdentity = IIdentity(l.identities[_userAddress].identity);
        l.identities[_userAddress].identity = identityAddr;

        emit IdentityUpdated(oldIdentity, _identityContract);
        emit IdentityModified(oldIdentity, _identityContract);
    }

    function _batchRegisterIdentity(
        address[] calldata _userAddresses,
        IIdentity[] calldata _identities,
        uint16[] calldata _countries
    ) internal onlyAgent {
        require(
            _userAddresses.length == _identities.length &&
                _userAddresses.length == _countries.length,
            "Array length mismatch"
        );

        for (uint256 i = 0; i < _userAddresses.length; i++) {
            _registerIdentity(_userAddresses[i], _identities[i], _countries[i]);
        }
    }

    function _contains(address _userAddress) internal view returns (bool) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();
        return l.identityExists[_userAddress];
    }

    function _isVerified(address _userAddress) internal view returns (bool) {
        return _contains(_userAddress);
    }

    function _identity(address _userAddress) internal view returns (IIdentity) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();
        return IIdentity(l.identities[_userAddress].identity);
    }

    function _investorCountry(
        address _userAddress
    ) internal view returns (uint16) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();
        return l.identities[_userAddress].country;
    }

    function _issuersRegistry()
        internal
        view
        returns (ITrustedIssuersRegistry)
    {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();
        return ITrustedIssuersRegistry(l.trustedIssuersRegistry);
    }

    function _topicsRegistry()
        internal
        view
        returns (IClaimTopicsRegistry)
    {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();
        return IClaimTopicsRegistry(l.claimTopicsRegistry);
    }

    // Storage functions
    function _identityStorage()
        internal
        view
        returns (IIdentityRegistryStorage)
    {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();
        return IIdentityRegistryStorage(l.identityStorage);
    }

    function _setIdentityRegistryStorage(
        address _identityStorageAddr
    ) internal onlyAgent {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();
        l.identityStorage = _identityStorageAddr;
        emit IdentityStorageSet(_identityStorageAddr);
    }

    function _storedIdentity(
        address _userAddress
    ) internal view returns (IIdentity) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();
        return IIdentity(l.identities[_userAddress].identity);
    }

    function _storedInvestorCountry(
        address _userAddress
    ) internal view returns (uint16) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();
        return l.identities[_userAddress].country;
    }

    function _addIdentityToStorage(
        address _userAddress,
        IIdentity _identityContract,
        uint16 _country
    ) internal {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();

        l.identities[_userAddress] = IdentityData({
            identity: address(_identityContract),
            country: _country
        });
        l.identityExists[_userAddress] = true;

        emit IdentityStored(_userAddress, _identityContract);
    }

    function _removeIdentityFromStorage(address _userAddress) internal {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();

        IIdentity oldIdentity = IIdentity(l.identities[_userAddress].identity);
        delete l.identities[_userAddress];
        l.identityExists[_userAddress] = false;

        emit IdentityUnstored(_userAddress, oldIdentity);
    }

    function _modifyStoredInvestorCountry(
        address _userAddress,
        uint16 _country
    ) internal {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();

        l.identities[_userAddress].country = _country;
        emit CountryModified(_userAddress, _country);
    }

    function _modifyStoredIdentity(
        address _userAddress,
        IIdentity _identityContract
    ) internal {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();

        IIdentity oldIdentity = IIdentity(l.identities[_userAddress].identity);
        l.identities[_userAddress].identity = address(_identityContract);
        emit IdentityModified(oldIdentity, _identityContract);
    }

    function _bindIdentityRegistry(
        address _identityRegistry
    ) internal onlyOwner {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();

        // Add to linked registries if not already present
        for (uint256 i = 0; i < l.linkedRegistries.length; i++) {
            if (l.linkedRegistries[i] == _identityRegistry) {
                return; // Already bound
            }
        }

        l.linkedRegistries.push(_identityRegistry);
        emit IdentityRegistryBound(_identityRegistry);
    }

    function _unbindIdentityRegistry(
        address _identityRegistry
    ) internal onlyOwner {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();

        // Remove from linked registries
        for (uint256 i = 0; i < l.linkedRegistries.length; i++) {
            if (l.linkedRegistries[i] == _identityRegistry) {
                l.linkedRegistries[i] = l.linkedRegistries[
                    l.linkedRegistries.length - 1
                ];
                l.linkedRegistries.pop();
                emit IdentityRegistryUnbound(_identityRegistry);
                return;
            }
        }
    }

    function _linkedIdentityRegistries()
        internal
        view
        returns (address[] memory)
    {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage
            .layout();
        return l.linkedRegistries;
    }
}
