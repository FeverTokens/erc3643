// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./ISystemOperation.sol";
import "./SystemOperationInternal.sol";

contract SystemOperation is ISystemOperation, SystemOperationInternal {
    function batchUpdateFrozenStatus(
        address[] calldata _addresses,
        bool[] calldata _statuses
    ) external override {
        _batchUpdateFrozenStatus(_addresses, _statuses);
    }

    function batchUpdateIdentityVerification(
        address[] calldata _addresses,
        bool[] calldata _verificationStatuses
    ) external override {
        _batchUpdateIdentityVerification(_addresses, _verificationStatuses);
    }

    function updateOnchainID(address _newOnchainID) external override {
        _updateOnchainID(_newOnchainID);
    }

    //  compliance-related functions such as setting the compliance contract, checking transfer compliance, and managing token pausing
    function setComplianceContract(address _compliance) external override {
        _setComplianceContract(_compliance);
    }

    function isTransferCompliant(
        address _from,
        address _to
    ) external view override returns (bool) {
        return _isTransferCompliant(_from, _to);
    }

    function setTokenPaused(bool _paused) external override {
        _setTokenPaused(_paused);
    }
}
