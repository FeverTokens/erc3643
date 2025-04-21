// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

library TokenOperationStorage {
    struct Layout {
        bool paused;
        bool tokenPaused;
        mapping(address => uint256) balances;
        mapping(address => uint256) stakedBalances;
        mapping(address => bool) walletFrozen;
        uint256 totalStaked;
    }

    bytes32 constant STORAGE_SLOT =
        keccak256(
            abi.encode(
                uint256(keccak256("ft.storage.TokenOperationStorage")) - 1
            )
        ) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
