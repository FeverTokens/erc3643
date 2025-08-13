// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IIdentityRegistryInternal.sol";
import "./IdentityRegistryStorage.sol";
import "../../access/rbac/AccessControlInternal.sol";

abstract contract IdentityRegistryInternal is IIdentityRegistryInternal, AccessControlInternal {
    using IdentityRegistryStorage for IdentityRegistryStorage.Layout;
    
    bytes32 internal constant AGENT_ROLE = keccak256("AGENT_ROLE");

    function _setClaimTopicsRegistry(address _claimTopicsRegistry) internal onlyRole(AGENT_ROLE) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage.layout();
        l.claimTopicsRegistry = _claimTopicsRegistry;
        emit ClaimTopicsRegistrySet(_claimTopicsRegistry);
    }

    function _setTrustedIssuersRegistry(address _trustedIssuersRegistry) internal onlyRole(AGENT_ROLE) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage.layout();
        l.trustedIssuersRegistry = _trustedIssuersRegistry;
        emit TrustedIssuersRegistrySet(_trustedIssuersRegistry);
    }

    function _registerIdentity(address _userAddress, address _identityAddr, uint16 _country) internal onlyRole(AGENT_ROLE) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage.layout();
        
        if (l.identityExists[_userAddress]) {
            revert IdentityAlreadyRegistered(_userAddress);
        }
        if (_identityAddr == address(0)) {
            revert InvalidIdentityAddress(_identityAddr);
        }
        
        l.identities[_userAddress] = IdentityData({
            identity: _identityAddr,
            country: _country
        });
        l.identityExists[_userAddress] = true;
        
        emit IdentityRegistered(_userAddress, _identityAddr);
        emit IdentityStored(_userAddress, _identityAddr);
    }

    function _deleteIdentity(address _userAddress) internal onlyRole(AGENT_ROLE) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage.layout();
        
        if (!l.identityExists[_userAddress]) {
            revert IdentityNotRegistered(_userAddress);
        }
        
        address oldIdentity = l.identities[_userAddress].identity;
        delete l.identities[_userAddress];
        l.identityExists[_userAddress] = false;
        
        emit IdentityRemoved(_userAddress, oldIdentity);
        emit IdentityUnstored(_userAddress, oldIdentity);
    }

    function _updateCountry(address _userAddress, uint16 _country) internal onlyRole(AGENT_ROLE) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage.layout();
        
        if (!l.identityExists[_userAddress]) {
            revert IdentityNotRegistered(_userAddress);
        }
        
        l.identities[_userAddress].country = _country;
        
        emit CountryUpdated(_userAddress, _country);
        emit CountryModified(_userAddress, _country);
    }

    function _updateIdentity(address _userAddress, address _identityAddr) internal onlyRole(AGENT_ROLE) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage.layout();
        
        if (!l.identityExists[_userAddress]) {
            revert IdentityNotRegistered(_userAddress);
        }
        if (_identityAddr == address(0)) {
            revert InvalidIdentityAddress(_identityAddr);
        }
        
        address oldIdentity = l.identities[_userAddress].identity;
        l.identities[_userAddress].identity = _identityAddr;
        
        emit IdentityUpdated(oldIdentity, _identityAddr);
        emit IdentityModified(oldIdentity, _identityAddr);
    }

    function _batchRegisterIdentity(
        address[] calldata _userAddresses,
        address[] calldata _identities,
        uint16[] calldata _countries
    ) internal onlyRole(AGENT_ROLE) {
        require(_userAddresses.length == _identities.length && _userAddresses.length == _countries.length, "Array length mismatch");
        
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            _registerIdentity(_userAddresses[i], _identities[i], _countries[i]);
        }
    }

    function _contains(address _userAddress) internal view returns (bool) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage.layout();
        return l.identityExists[_userAddress];
    }

    function _isVerified(address _userAddress) internal view returns (bool) {
        // This would integrate with claim verification logic
        // For now, returning simple existence check
        // TODO: Implement full claim verification with ClaimTopicsRegistry and TrustedIssuersRegistry
        return _contains(_userAddress);
    }

    function _identity(address _userAddress) internal view returns (address) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage.layout();
        return l.identities[_userAddress].identity;
    }

    function _investorCountry(address _userAddress) internal view returns (uint16) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage.layout();
        return l.identities[_userAddress].country;
    }

    function _issuersRegistry() internal view returns (address) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage.layout();
        return l.trustedIssuersRegistry;
    }

    function _topicsRegistry() internal view returns (address) {
        IdentityRegistryStorage.Layout storage l = IdentityRegistryStorage.layout();
        return l.claimTopicsRegistry;
    }
}