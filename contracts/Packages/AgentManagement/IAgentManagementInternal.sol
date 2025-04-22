// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
pragma experimental ABIEncoderV2;

interface IAgentManagementInternal {
    enum AgentRole {
        Owner,
        Agent
    }

    struct Agent {
        address addr;
        AgentRole role;
    }

    //Events
    event AgentAdded(address indexed _agent, AgentRole indexed);

    event AgentRemoved(address indexed _agent, AgentRole indexed _role);

    event IdentityVerificationUpdated(address indexed user, bool isVerified);
}
