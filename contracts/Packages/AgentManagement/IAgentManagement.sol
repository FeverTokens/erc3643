// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IAgentManagementInternal.sol";

interface IAgentManagement is IAgentManagementInternal {
    // Adds an agent to the system
    function addAgent(address _agent) external;

    // Removes an agent from the system
    function removeAgent(address _agent) external;

    // Checks if an address is an agent
    function isAgent(address _agent) external view returns (bool);
}
