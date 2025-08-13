// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IClaimTopicsRegistryInternal {
    // Events
    event ClaimTopicAdded(uint256 indexed claimTopic);
    event ClaimTopicRemoved(uint256 indexed claimTopic);

    // Errors
    error ClaimTopicAlreadyExists(uint256 claimTopic);
    error ClaimTopicNotFound(uint256 claimTopic);
    error InvalidClaimTopic(uint256 claimTopic);
}