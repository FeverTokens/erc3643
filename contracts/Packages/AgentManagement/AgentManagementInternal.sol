// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IAgentManagementInternal.sol";
import "./AgentManagementStorage.sol";
import "../../access/rbac/AccessControlInternal.sol";
import "../../access/rbac/AccessControlStorage.sol";
import "../../data/EnumerableSet.sol";



abstract contract AgentManagementInternal is IAgentManagementInternal, AccessControlInternal{
   
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 internal constant AGENT_ROLE = keccak256("AGENT_ROLE");

    function _addAgent(address _agent) internal onlyRole(AGENT_ROLE){
        AgentManagementStorage.Layout storage l = AgentManagementStorage
            .layout();
        l.agents[_agent] = true;

        AccessControlStorage.layout().roles[AGENT_ROLE].roleMembers.add(_agent);

        emit AgentAdded(_agent);
    }

    function _removeAgent(address _agent) internal onlyRole(AGENT_ROLE) {
        AgentManagementStorage.Layout storage l = AgentManagementStorage
            .layout();
        l.agents[_agent] = false;

        AccessControlStorage.layout().roles[AGENT_ROLE].roleMembers.remove(_agent);

        emit AgentRemoved(_agent);
    }

    function _isAgent(address _agent) internal view returns (bool) {
        AgentManagementStorage.Layout storage l = AgentManagementStorage
            .layout();
        return l.agents[_agent];
    }
}
