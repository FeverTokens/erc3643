// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IAgentRole.sol";
import "./AgentRoleInternal.sol";
import "../../access/rbac/AccessControlStorage.sol";
import "../../data/EnumerableSet.sol";

contract AgentRole is IAgentRole, AgentRoleInternal {
    using EnumerableSet for EnumerableSet.AddressSet;

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
