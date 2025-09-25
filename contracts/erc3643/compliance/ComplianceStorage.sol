// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library ComplianceStorage {
    struct Layout {
        // Bound token address
        address boundToken;
        // Compliance state tracking
        mapping(address => uint256) holderBalance;
        uint256 totalSupply;
        // Country-specific limits
        mapping(uint16 => uint256) maxTokensPerCountry;
        mapping(uint16 => uint256) tokensPerCountry;
        // Investor limits
        uint256 maxTokensPerInvestor;
        uint256 maxInvestors;
        uint256 currentInvestors;
        // Transfer restrictions
        mapping(address => mapping(address => bool)) transferRestrictions;
    }

    bytes32 constant STORAGE_SLOT =
        keccak256(
            abi.encode(uint256(keccak256("fevertokens.storage.Compliance")) - 1)
        ) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
