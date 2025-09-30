// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ITrustedIssuersRegistryInternal.sol";

library TrustedIssuersRegistryStorage {
    struct Layout {
        // Mapping from issuer address to trusted issuer data
        mapping(address => ITrustedIssuersRegistryInternal.TrustedIssuer) trustedIssuers;
        // Array of all trusted issuer addresses for enumeration
        IClaimIssuer[] issuersList;
        // Mapping to track issuer index in the array for efficient removal
        mapping(address => uint256) issuerIndex;
        // Mapping from claim topic to list of issuers that can issue that topic
        mapping(uint256 => IClaimIssuer[]) issuersForClaimTopic;
        // Mapping to track issuer index in each claim topic array
        mapping(uint256 => mapping(address => uint256)) issuerTopicIndex;
    }

    bytes32 constant STORAGE_SLOT =
        keccak256(
            abi.encode(
                uint256(
                    keccak256("fevertokens.storage.TrustedIssuersRegistry")
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
