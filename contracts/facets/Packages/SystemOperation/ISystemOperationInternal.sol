// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

interface ISystemOperationInternal{

    struct ComplianceCheck{
        bool isCompliant;
        string reason;
    }

    //Events
    event TokenPaused(bool paused);
    event ComplianceContractSet(address indexed complianceContract);
    event OnchainIDUpdated(address indexed newOnchainID);
    event WalletFrozenStatusUpdated(address indexed user, bool isFrozen);
    event TransferERC3643ComplianceCheck(address indexed from, address indexed to, uint256 value, ComplianceCheck complianceCheck);
    event IdentityVerificationUpdated(address indexed user, bool isVerified);

    
}