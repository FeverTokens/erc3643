// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IAgentManagementInternal.sol";
import "./AgentManagementStorage.sol";

abstract contract AgentManagementInternal is IAgentManagementInternal {
    using AgentManagementStorage for AgentManagementStorage.Layout;

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

    function _verifyIdentity(
        address _userAddress
    ) internal view returns (bool) {
        AgentManagementStorage.Layout storage l = AgentManagementStorage
            .layout();

        return l.agents[_userAddress];
    }

    function _batchUpdateIdentityVerification(
        address[] calldata _addresses,
        bool[] calldata _verificationStatuses
    ) internal {
        AgentManagementStorage.Layout storage l = AgentManagementStorage
            .layout();
        require(
            _addresses.length == _verificationStatuses.length,
            "Mismatched addresses and verification statuses"
        );
        for (uint256 i = 0; i < _addresses.length; i++) {
            l.agents[_addresses[i]] = _verificationStatuses[i];
            emit IdentityVerificationUpdated(
                _addresses[i],
                _verificationStatuses[i]
            );
        }
    }
}
