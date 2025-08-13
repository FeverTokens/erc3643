// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IClaimTopicsRegistryInternal.sol";

interface IClaimTopicsRegistry is IClaimTopicsRegistryInternal {
    // Setters
    function addClaimTopic(uint256 _claimTopic) external;
    function removeClaimTopic(uint256 _claimTopic) external;

    // Getter
    function getClaimTopics() external view returns (uint256[] memory);
}