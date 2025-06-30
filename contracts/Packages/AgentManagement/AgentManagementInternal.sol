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
    bytes32 internal constant OWNER_ROLE = keccak256("OWNER_ROLE");

    function _addAgent(address _agent) internal onlyRole(OWNER_ROLE){
        AgentManagementStorage.Layout storage l = AgentManagementStorage
            .layout();
        l.agents[_agent] = true;

        _grantRole(AGENT_ROLE,_agent);

        emit AgentAdded(_agent);
    }

    function _removeAgent(address _agent) internal onlyRole(OWNER_ROLE) {
        AgentManagementStorage.Layout storage l = AgentManagementStorage
            .layout();
        l.agents[_agent] = false;

       _revokeRole(AGENT_ROLE,_agent);

        emit AgentRemoved(_agent);
    }

    function _isAgent(address _agent) internal view returns (bool) {
        AgentManagementStorage.Layout storage l = AgentManagementStorage
            .layout();
        return l.agents[_agent];
    }
}
