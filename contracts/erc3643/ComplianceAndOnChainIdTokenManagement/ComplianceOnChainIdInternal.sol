// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IComplianceOnChainIdInternal.sol";
import "./ComplianceOnChainIdStorage.sol";

abstract contract ComplianceOnChainIdInternal is IComplianceOnChainIdInternal {
    using ComplianceOnChainIdStorage for ComplianceOnChainIdStorage.Layout;

    function _setComplianceContract(address _compliance) internal {
        ComplianceOnChainIdStorage.Layout storage l = ComplianceOnChainIdStorage
            .layout();
        l.complianceContract = _compliance;
        emit ComplianceContractSet(_compliance);
    }

    function _isTransferCompliant(
        address _from,
        address _to
    ) internal view returns (bool) {
        ComplianceOnChainIdStorage.Layout storage l = ComplianceOnChainIdStorage
            .layout();

        // Check if both the sender and receiver are verified identities
        bool fromIsVerified = l.verifiedIdentities[_from];
        bool toIsVerified = l.verifiedIdentities[_to];

        // A transfer is compliant if both the sender and receiver are verified
        return fromIsVerified && toIsVerified;
    }

    function _updateOnchainID(address _newOnchainID) internal {
        ComplianceOnChainIdStorage.Layout storage l = ComplianceOnChainIdStorage
            .layout();
        l.onchainID = _newOnchainID;
        emit OnchainIDUpdated(_newOnchainID);
    }

    function _verifyIdentity(
        address _userAddress
    ) internal view returns (bool) {
        ComplianceOnChainIdStorage.Layout storage l = ComplianceOnChainIdStorage
            .layout();

        return l.verifiedIdentities[_userAddress];
    }

    function _batchUpdateIdentityVerification(
        address[] calldata _addresses,
        bool[] calldata _verificationStatuses
    ) internal {
        ComplianceOnChainIdStorage.Layout storage l = ComplianceOnChainIdStorage
            .layout();
        require(
            _addresses.length == _verificationStatuses.length,
            "Mismatched addresses and verification statuses"
        );
        for (uint256 i = 0; i < _addresses.length; i++) {
            l.verifiedIdentities[_addresses[i]] = _verificationStatuses[i];
            emit IdentityVerificationUpdated(
                _addresses[i],
                _verificationStatuses[i]
            );
        }
    }
}
