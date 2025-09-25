// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IClaimTopicsRegistryInternal.sol";

/**
 * @title Claim Topics Registry Interface
 * @notice Interface for managing required claim topics in the ERC3643 ecosystem
 * @dev This interface extends IClaimTopicsRegistryInternal and provides external functions for claim topic management
 */
interface IClaimTopicsRegistry is IClaimTopicsRegistryInternal {
    /**
     * @notice Adds a new required claim topic to the registry
     * @dev Only the contract owner can call this function
     * @param _claimTopic The claim topic ID to add to the required list
     */
    function addClaimTopic(uint256 _claimTopic) external;
    
    /**
     * @notice Removes a claim topic from the required list
     * @dev Only the contract owner can call this function
     * @param _claimTopic The claim topic ID to remove from the required list
     */
    function removeClaimTopic(uint256 _claimTopic) external;

    /**
     * @notice Returns all required claim topics
     * @return uint256[] Array of required claim topic IDs
     */
    function getClaimTopics() external view returns (uint256[] memory);
}