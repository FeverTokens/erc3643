// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IAgentManagementInternal.sol";
import "./AgentManagementStorage.sol";

abstract contract AgentManagementInternal is IAgentManagementInternal {
    using AgentManagementStorage for AgentManagementStorage.Layout;

    modifier onlyAgent() {
        require(
            _isAgent(msg.sender),
            "AgentRole: caller does not have the Agent role"
        );
        _;
    }

    function _addAgent(address _agent) internal {
        AgentManagementStorage.Layout storage l = AgentManagementStorage
            .layout();
        l.agents[_agent] = true;
        emit AgentAdded(_agent, AgentRole.Agent);
    }

    function _removeAgent(address _agent) internal {
        AgentManagementStorage.Layout storage l = AgentManagementStorage
            .layout();
        l.agents[_agent] = false;
        emit AgentRemoved(_agent, AgentRole.Agent);
    }

    function _isAgent(address _agent) internal view returns (bool) {
        AgentManagementStorage.Layout storage l = AgentManagementStorage
            .layout();
        return l.agents[_agent];
    }
}
