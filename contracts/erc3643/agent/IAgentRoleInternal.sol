// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title Agent Role Internal Interface
 * @notice Internal interface defining events for agent role management
 * @dev This interface contains events emitted during agent operations
 */
interface IAgentRoleInternal {
    /**
     * @notice Emitted when a new agent is added to the system
     * @param _agent The address that was granted agent privileges
     */
    event AgentAdded(address indexed _agent);

    /**
     * @notice Emitted when an agent is removed from the system
     * @param _agent The address that had agent privileges revoked
     */
    event AgentRemoved(address indexed _agent);

    // add custom error for onlyOwner and onlyAgent modifiers with custom name
    /**
     * @notice Emitted when an unauthorized address attempts owner operations
     * @param account The address that attempted the unauthorized operation
     */
    error NotAnOwner(address account);

    /**
     * @notice Emitted when an unauthorized address attempts agent operations
     * @param account The address that attempted the unauthorized operation
     */
    error NotAnAgent(address account);
}
