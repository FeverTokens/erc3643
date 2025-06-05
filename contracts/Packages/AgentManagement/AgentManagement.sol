// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IAgentManagement.sol";
import "./AgentManagementInternal.sol";
import "../../access/rbac/AccessControlStorage.sol";
import "../../data/EnumerableSet.sol";

contract AgentManagement is IAgentManagement, AgentManagementInternal {

    using EnumerableSet for EnumerableSet.AddressSet;

    function init() external{
         AgentManagementStorage.Layout storage l = AgentManagementStorage
            .layout();
        l.agents[msg.sender] = true;

        AccessControlStorage.layout().roles[AGENT_ROLE].roleMembers.add(msg.sender);
    }

    function addAgent(address _agent) external override {
        _addAgent(_agent);
    }

    function removeAgent(address _agent) external override {
        _removeAgent(_agent);
    }

    function isAgent(address _agent) external view override returns (bool) {
        return _isAgent(_agent);
    }
}
