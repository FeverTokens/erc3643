// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

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
}
