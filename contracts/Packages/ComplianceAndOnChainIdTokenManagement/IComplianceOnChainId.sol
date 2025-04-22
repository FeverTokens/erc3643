// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IComplianceOnChainIdInternal.sol";

interface IComplianceOnChainId is IComplianceOnChainIdInternal {
    // Updates the on-chain ID of the token
    function updateOnchainID(address _newOnchainID) external;

    // Sets the compliance contract for the token
    function setComplianceContract(address _compliance) external;

    // Checks if a transfer is compliant
    function isTransferCompliant(
        address _from,
        address _to
    ) external view returns (bool);

    // Checks if a user's identity is verified
    function isVerified(address _userAddress) external view returns (bool);

    function batchUpdateIdentityVerification(
        address[] calldata _addresses,
        bool[] calldata _verificationStatuses
    ) external;
}
