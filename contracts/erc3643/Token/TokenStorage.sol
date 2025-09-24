// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library TokenStorage {
    struct Layout {
        // Token metadata
        string name;
        string symbol;
        uint8 decimals;
        address onchainID;
        // ERC20 state
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
        uint256 totalSupply;
        // ERC3643 specific state
        address identityRegistry;
        address compliance;
        // Pause state
        bool paused;
        // Frozen addresses
        mapping(address => bool) frozen;
        // Frozen tokens per address
        mapping(address => uint256) frozenTokens;
        // Recovery history
        mapping(address => address) recoveries;
    }

    bytes32 constant STORAGE_SLOT =
        keccak256(
            abi.encode(uint256(keccak256("fevertokens.storage.Token")) - 1)
        ) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
