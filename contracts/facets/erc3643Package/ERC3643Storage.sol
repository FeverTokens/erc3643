// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

library ERC3643Storage {
    struct Layout {
        uint256 totalSupply;
        
        mapping(address => bool) agents;
        mapping(address => bool) verifiedIdentities;
        mapping(address => uint256) frozenTokens;
        mapping(address => uint256) balances;
        bool paused;
        bool tokenPaused;
        // Recovery System
        mapping(address => address) recoveryAddresses;
        // Token Management
        mapping(address => uint256) stakedBalances;
        uint256 totalStaked;
        
        // Wallet Frozen Status
        mapping(address => bool) walletFrozen;
        // Compliance System
        address complianceContract;
        // Onchain ID
        address onchainID;
    }

    bytes32 constant STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256("ft.storage.erc3643")) - 1)) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

  
}