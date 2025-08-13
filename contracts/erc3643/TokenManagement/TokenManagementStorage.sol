// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library TokenManagementStorage {
    struct Layout {
        mapping(address => uint256) frozenTokens;
        bool tokenPaused;
    }

    bytes32 constant STORAGE_SLOT =
        keccak256(
            abi.encode(
                uint256(keccak256("fevertokens.storage.TokenManagement")) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
