// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IAgentManagement.sol";
import "./AgentManagementInternal.sol";

contract AgentManagement is IAgentManagement, AgentManagementInternal {
    function addAgent(address _agent) external override {
        _addAgent(_agent);
    }

    function removeAgent(address _agent) external override {
        _removeAgent(_agent);
    }

    function isAgent(address _agent) external view override returns (bool) {
        return _isAgent(_agent);
    }

    function isVerified(
        address _userAddress
    ) external view override returns (bool) {
        return _verifyIdentity(_userAddress);
    }

    function batchUpdateIdentityVerification(
        address[] calldata _addresses,
        bool[] calldata _verificationStatuses
    ) external override {
        _batchUpdateIdentityVerification(_addresses, _verificationStatuses);
    }
}
