// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IComplianceOnChainIdInternal {
    struct ComplianceCheck {
        bool isCompliant;
        string reason;
    }

    //Events
    event ComplianceContractSet(address indexed complianceContract);

    event OnchainIDUpdated(address indexed newOnchainID);

    event TransferERC3643ComplianceCheck(
        address indexed from,
        address indexed to,
        uint256 value,
        ComplianceCheck complianceCheck
    );

    event IdentityVerificationUpdated(address indexed user, bool isVerified);
}
