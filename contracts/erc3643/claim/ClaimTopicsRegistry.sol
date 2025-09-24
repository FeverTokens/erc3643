// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IClaimTopicsRegistry.sol";
import "./ClaimTopicsRegistryInternal.sol";

contract ClaimTopicsRegistry is IClaimTopicsRegistry, ClaimTopicsRegistryInternal {
    
    // Setters
    function addClaimTopic(uint256 _claimTopic) external override {
        _addClaimTopic(_claimTopic);
    }
    
    function removeClaimTopic(uint256 _claimTopic) external override {
        _removeClaimTopic(_claimTopic);
    }

    // Getter
    function getClaimTopics() external view override returns (uint256[] memory) {
        return _getClaimTopics();
    }
}