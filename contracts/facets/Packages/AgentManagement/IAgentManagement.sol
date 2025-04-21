// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./IAgentManagementInternal.sol";

interface IAgentManagement is IAgentManagementInternal {
    // Adds an agent to the system
    function addAgent(address _agent) external;

    // Removes an agent from the system
    function removeAgent(address _agent) external;

    // Checks if an address is an agent
    function isAgent(address _agent) external view returns (bool);

    // Checks if a user's identity is verified
    function isVerified(address _userAddress) external view returns (bool);
}
