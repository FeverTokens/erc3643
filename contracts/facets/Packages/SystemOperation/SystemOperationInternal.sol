// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./ISystemOperationInternal.sol";
import "./SystemOperationStorage.sol";

abstract contract SystemOperationInternal is ISystemOperationInternal {
    using SystemOperationStorage for SystemOperationStorage.Layout;

    function _setTokenPaused(bool _paused) internal {
        SystemOperationStorage.Layout storage l = SystemOperationStorage
            .layout();
        l.tokenPaused = _paused;
        emit TokenPaused(_paused);
    }

    function _batchUpdateFrozenStatus(
        address[] calldata _addresses,
        bool[] calldata _statuses
    ) internal {
        SystemOperationStorage.Layout storage l = SystemOperationStorage
            .layout();
        require(
            _addresses.length == _statuses.length,
            "Mismatched addresses and statuses"
        );
        for (uint256 i = 0; i < _addresses.length; i++) {
            l.walletFrozen[_addresses[i]] = _statuses[i];
            emit WalletFrozenStatusUpdated(_addresses[i], _statuses[i]);
        }
    }

    function _batchUpdateIdentityVerification(
        address[] calldata _addresses,
        bool[] calldata _verificationStatuses
    ) internal {
        SystemOperationStorage.Layout storage l = SystemOperationStorage
            .layout();
        require(
            _addresses.length == _verificationStatuses.length,
            "Mismatched addresses and verification statuses"
        );
        for (uint256 i = 0; i < _addresses.length; i++) {
            l.agents[_addresses[i]] = _verificationStatuses[i];
            emit IdentityVerificationUpdated(
                _addresses[i],
                _verificationStatuses[i]
            );
        }
    }

    function _setComplianceContract(address _compliance) internal {
        SystemOperationStorage.Layout storage l = SystemOperationStorage
            .layout();
        l.complianceContract = _compliance;
        emit ComplianceContractSet(_compliance);
    }

    function _isTransferCompliant(
        address _from,
        address _to
    ) internal view returns (bool) {
        SystemOperationStorage.Layout storage l = SystemOperationStorage
            .layout();

        // Check if both the sender and receiver are verified identities
        bool fromIsVerified = l.verifiedIdentities[_from];
        bool toIsVerified = l.verifiedIdentities[_to];

        // A transfer is compliant if both the sender and receiver are verified
        return fromIsVerified && toIsVerified;
    }

    function _updateOnchainID(address _newOnchainID) internal {
        SystemOperationStorage.Layout storage l = SystemOperationStorage
            .layout();
        l.onchainID = _newOnchainID;
        emit OnchainIDUpdated(_newOnchainID);
    }
}
