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
}
