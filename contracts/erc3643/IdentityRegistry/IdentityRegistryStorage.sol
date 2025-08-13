// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IIdentityRegistryInternal.sol";

library IdentityRegistryStorage {
    struct Layout {
        // Identity registry data
        mapping(address => IIdentityRegistryInternal.IdentityData) identities;
        mapping(address => bool) identityExists;
        
        // Registry addresses
        address claimTopicsRegistry;
        address trustedIssuersRegistry;
        
        // Linked registries for shared storage
        address[] linkedRegistries;
        mapping(address => bool) isLinkedRegistry;
    }

    bytes32 constant STORAGE_SLOT =
        keccak256(
            abi.encode(
                uint256(keccak256("fevertokens.storage.IdentityRegistry")) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}