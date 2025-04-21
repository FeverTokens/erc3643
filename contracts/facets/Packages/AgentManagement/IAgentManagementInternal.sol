// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
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
}
