// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IClaimTopicsRegistryInternal.sol";
import "./ClaimTopicsRegistryStorage.sol";
import "../../access/rbac/AccessControlInternal.sol";

abstract contract ClaimTopicsRegistryInternal is IClaimTopicsRegistryInternal, AccessControlInternal {
    using ClaimTopicsRegistryStorage for ClaimTopicsRegistryStorage.Layout;
    
    bytes32 internal constant OWNER_ROLE = keccak256("OWNER_ROLE");

    function _addClaimTopic(uint256 _claimTopic) internal onlyRole(OWNER_ROLE) {
        ClaimTopicsRegistryStorage.Layout storage l = ClaimTopicsRegistryStorage.layout();
        
        if (_claimTopic == 0) {
            revert InvalidClaimTopic(_claimTopic);
        }
        if (l.claimTopicExists[_claimTopic]) {
            revert ClaimTopicAlreadyExists(_claimTopic);
        }
        
        // Add claim topic to the array
        l.claimTopicIndex[_claimTopic] = l.claimTopics.length;
        l.claimTopics.push(_claimTopic);
        l.claimTopicExists[_claimTopic] = true;
        
        emit ClaimTopicAdded(_claimTopic);
    }

    function _removeClaimTopic(uint256 _claimTopic) internal onlyRole(OWNER_ROLE) {
        ClaimTopicsRegistryStorage.Layout storage l = ClaimTopicsRegistryStorage.layout();
        
        if (!l.claimTopicExists[_claimTopic]) {
            revert ClaimTopicNotFound(_claimTopic);
        }
        
        // Remove from array by swapping with last element
        uint256 index = l.claimTopicIndex[_claimTopic];
        uint256 lastIndex = l.claimTopics.length - 1;
        
        if (index != lastIndex) {
            uint256 lastClaimTopic = l.claimTopics[lastIndex];
            l.claimTopics[index] = lastClaimTopic;
            l.claimTopicIndex[lastClaimTopic] = index;
        }
        
        l.claimTopics.pop();
        delete l.claimTopicIndex[_claimTopic];
        l.claimTopicExists[_claimTopic] = false;
        
        emit ClaimTopicRemoved(_claimTopic);
    }

    function _getClaimTopics() internal view returns (uint256[] memory) {
        ClaimTopicsRegistryStorage.Layout storage l = ClaimTopicsRegistryStorage.layout();
        return l.claimTopics;
    }
}