// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title Claim Topics Registry Internal Interface
 * @notice Internal interface defining events and errors for claim topics registry operations
 * @dev This interface contains events and errors emitted during claim topic management
 */
interface IClaimTopicsRegistryInternal {
    /**
     * @notice Emitted when a claim topic is added to the registry
     * @param claimTopic The claim topic ID that was added
     */
    event ClaimTopicAdded(uint256 indexed claimTopic);
    
    /**
     * @notice Emitted when a claim topic is removed from the registry
     * @param claimTopic The claim topic ID that was removed
     */
    event ClaimTopicRemoved(uint256 indexed claimTopic);

    /**
     * @notice Error thrown when trying to add a claim topic that already exists
     * @param claimTopic The claim topic ID that already exists
     */
    error ClaimTopicAlreadyExists(uint256 claimTopic);
    
    /**
     * @notice Error thrown when trying to remove a claim topic that doesn't exist
     * @param claimTopic The claim topic ID that was not found
     */
    error ClaimTopicNotFound(uint256 claimTopic);
    
    /**
     * @notice Error thrown when an invalid claim topic ID is provided
     * @param claimTopic The invalid claim topic ID
     */
    error InvalidClaimTopic(uint256 claimTopic);
}