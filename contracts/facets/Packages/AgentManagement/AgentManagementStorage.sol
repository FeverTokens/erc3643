pragma solidity >=0.7.0 <0.9.0;

library AgentManagementStorage{
    struct Layout{
        mapping(address => bool) agents;
        mapping(address => bool) verifiedIdentities;
    }

    bytes32 constant STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256("ft.storage.AgentManagementStorage")) - 1)) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}