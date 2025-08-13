// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library ComplianceOnChainIdStorage {
    struct Layout {
        // Recovery System
        mapping(address => address) recoveryAddresses;
        mapping(address => bool) verifiedIdentities;
        address complianceContract; // Compliance System
        address onchainID;
    }

    bytes32 constant STORAGE_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256(
                        "fevertokens.storage.ComplianceAndOnChainIdTokenManagement"
                    )
                ) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
