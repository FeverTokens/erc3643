// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IComplianceInternal {
    // Events
    event TokenBound(address indexed token);
    event TokenUnbound(address indexed token);
    event ComplianceTransferred(address indexed from, address indexed to, uint256 amount);
    event ComplianceCreated(address indexed to, uint256 amount);
    event ComplianceDestroyed(address indexed from, uint256 amount);

    // Errors
    error TokenAlreadyBound(address token);
    error TokenNotBound(address token);
    error InvalidTokenAddress(address token);
    error ComplianceCheckFailed(address from, address to, uint256 amount);
}