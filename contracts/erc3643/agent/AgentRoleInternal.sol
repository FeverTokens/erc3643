// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../../access/rbac/AccessControlInternal.sol";
import "../../access/rbac/AccessControlStorage.sol";
import "../../access/ownable/OwnableInternal.sol";
import "../../data/EnumerableSet.sol";
import "./IAgentRoleInternal.sol";
import "./AgentRoleStorage.sol";

abstract contract AgentRoleInternal is
    IAgentRoleInternal,
    AccessControlInternal,
    OwnableInternal
{
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 internal constant AGENT_ROLE = keccak256("AGENT_ROLE");

    function __AgentRoleInternal_init() internal {
        __AgentRoleInternal_init_unchained();
    }

    function __AgentRoleInternal_init_unchained() internal {}

    modifier onlyAgent() {
        if (!_isAgent(msg.sender)) {
            revert NotAnAgent(msg.sender);
        }
        _;
    }

    function _addAgent(address _agent) internal onlyOwner {
        AgentRoleStorage.Layout storage l = AgentRoleStorage.layout();
        l.agents[_agent] = true;

        _grantRole(AGENT_ROLE, _agent);

        emit AgentAdded(_agent);
    }

    function _removeAgent(address _agent) internal onlyOwner {
        AgentRoleStorage.Layout storage l = AgentRoleStorage.layout();
        l.agents[_agent] = false;

        _revokeRole(AGENT_ROLE, _agent);

        emit AgentRemoved(_agent);
    }

    function _isAgent(address _agent) internal view returns (bool) {
        AgentRoleStorage.Layout storage l = AgentRoleStorage.layout();
        return l.agents[_agent];
    }
}
