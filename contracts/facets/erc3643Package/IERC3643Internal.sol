// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

interface IERC3643Internal {
    // Enums
    enum AgentRole { Owner, Agent }

    // Structs
    struct Agent {
        address addr;
        AgentRole role;
    }

    struct ComplianceCheck {
        bool isCompliant;
        string reason;
    }

    // Events
    event AgentAdded(address indexed _agent, AgentRole indexed _role);
    event AgentRemoved(address indexed _agent, AgentRole indexed _role);
    event TransferERC3643(address indexed from, address indexed to, uint256 value);
    event TokensFrozen(address indexed user, uint256 amount);
    event TokensUnfrozen(address indexed user, uint256 amount);
    event WalletFrozen(address indexed user);
    event WalletUnfrozen(address indexed user);
    event TokenPaused(bool paused);
    event ComplianceContractSet(address indexed complianceContract);
    event OnchainIDUpdated(address indexed newOnchainID);
    event IdentityVerificationUpdated(address indexed user, bool isVerified);
    event WalletFrozenStatusUpdated(address indexed user, bool isFrozen);
    event TransferERC3643ComplianceCheck(address indexed from, address indexed to, uint256 value, ComplianceCheck complianceCheck);
}