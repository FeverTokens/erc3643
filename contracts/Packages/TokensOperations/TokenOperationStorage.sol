// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library TokenOperationStorage {
    struct Layout {
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalStaked;
        uint256 totalSupply;
        mapping(address => uint256) balances;
        mapping(address => uint256) stakedBalances;
        mapping(address => bool) walletFrozen;
    }

    bytes32 constant STORAGE_SLOT =
        keccak256(
            abi.encode(
                uint256(keccak256("fevertokens.storage.TokenOperation")) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
