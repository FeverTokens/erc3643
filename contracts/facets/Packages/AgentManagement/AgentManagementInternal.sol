// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./IAgentManagementInternal.sol";
import "./AgentManagementStorage.sol";

abstract contract AgentManagementInternal is IAgentManagementInternal {
    using AgentManagementStorage for AgentManagementStorage.Layout;
     
    function _addAgent(address _agent) internal {
        AgentManagementStorage.Layout storage l = AgentManagementStorage.layout();
        l.agents[_agent] = true;
        emit AgentAdded(_agent, AgentRole.Agent);
    } 

    function _removeAgent(address _agent) internal{
        AgentManagementStorage.Layout storage l = AgentManagementStorage.layout();
        l.agents[_agent] = false;
        emit AgentRemoved(_agent, AgentRole.Agent);
    }

    function _isAgent(address _agent) internal view returns(bool){
        AgentManagementStorage.Layout storage l = AgentManagementStorage.layout();
        return l.agents[_agent];
    }

    function _verifyIdentity(address _userAddress) internal view returns(bool){
         AgentManagementStorage.Layout storage l = AgentManagementStorage.layout();
         
         return l.agents[_userAddress];
    }
    
}