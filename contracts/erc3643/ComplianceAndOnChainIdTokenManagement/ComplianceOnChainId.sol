// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IComplianceOnChainId.sol";
import "./ComplianceOnChainIdInternal.sol";

contract ComplianceOnChainId is
    IComplianceOnChainId,
    ComplianceOnChainIdInternal
{
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

    function isVerified(address _userAddress) external view returns (bool) {
        return _verifyIdentity(_userAddress);
    }

    function batchUpdateIdentityVerification(
        address[] calldata _addresses,
        bool[] calldata _verificationStatuses
    ) external {
        _batchUpdateIdentityVerification(_addresses, _verificationStatuses);
    }
}
