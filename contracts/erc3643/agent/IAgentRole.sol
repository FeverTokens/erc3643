// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IAgentRoleInternal.sol";

/**
 * @title Agent Role Management Interface
 * @notice Interface for managing agent roles in the ERC3643 ecosystem
 * @dev This interface extends IAgentRoleInternal and provides external functions for agent management
 */
interface IAgentRole is IAgentRoleInternal {
    /**
     * @notice Adds a new agent to the system
     * @dev Only the contract owner can call this function
     * @param _agent The address to be granted agent privileges
     */
    function addAgent(address _agent) external;

    /**
     * @notice Removes an agent from the system
     * @dev Only the contract owner can call this function
     * @param _agent The address to have agent privileges revoked
     */
    function removeAgent(address _agent) external;

    /**
     * @notice Checks if an address has agent privileges
     * @param _agent The address to check
     * @return bool True if the address is an agent, false otherwise
     */
    function isAgent(address _agent) external view returns (bool);
}
