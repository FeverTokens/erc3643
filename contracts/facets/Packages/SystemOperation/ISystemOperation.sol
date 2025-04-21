// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./ISystemOperationInternal.sol";

interface ISystemOperation is ISystemOperationInternal {
    // Updates the on-chain ID of the token
    function updateOnchainID(address _newOnchainID) external;

    // Sets the compliance contract for the token
    function setComplianceContract(address _compliance) external;

    // Checks if a transfer is compliant
    function isTransferCompliant(
        address _from,
        address _to
    ) external view returns (bool);

    // Batch updates the frozen status of multiple addresses
    function batchUpdateFrozenStatus(
        address[] calldata _addresses,
        bool[] calldata _statuses
    ) external;

    // Batch updates the identity verification status of multiple addresses
    function batchUpdateIdentityVerification(
        address[] calldata _addresses,
        bool[] calldata _verificationStatuses
    ) external;

    // Sets the token to paused or unpaused state
    function setTokenPaused(bool _paused) external;
}
