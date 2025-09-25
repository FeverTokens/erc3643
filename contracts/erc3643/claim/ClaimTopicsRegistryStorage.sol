// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library ClaimTopicsRegistryStorage {
    struct Layout {
        // Array of required claim topics
        uint256[] claimTopics;
        
        // Mapping to check if a claim topic exists
        mapping(uint256 => bool) claimTopicExists;
        
        // Mapping to track claim topic index in the array for efficient removal
        mapping(uint256 => uint256) claimTopicIndex;
    }

    bytes32 constant STORAGE_SLOT =
        keccak256(
            abi.encode(
                uint256(keccak256("fevertokens.storage.ClaimTopicsRegistry")) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}