// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

library TokenManagementStorage {
    struct Layout {
        uint256 totalSupply;
        mapping(address => uint256) frozenTokens;
        mapping(address => bool) walletFrozen;
        mapping(address => uint256) balances;
    }

    bytes32 constant STORAGE_SLOT =
        keccak256(
            abi.encode(uint256(keccak256("ft.storage.TokenManagement")) - 1)
        ) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
