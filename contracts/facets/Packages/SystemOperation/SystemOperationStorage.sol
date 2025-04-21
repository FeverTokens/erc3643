// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

library SystemOperationStorage{
    struct Layout{
        // Recovery System
        mapping(address => address) recoveryAddresses;

        mapping(address => bool) walletFrozen;

        mapping(address => bool) agents;

        mapping(address => bool) verifiedIdentities;

        // Compliance System
        address complianceContract;
        // Onchain ID
        address onchainID;

         bool tokenPaused; 
    }

     bytes32 constant STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256("ft.storage.SystemOperation")) - 1)) & ~bytes32(uint256(0xff));

     function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }


}