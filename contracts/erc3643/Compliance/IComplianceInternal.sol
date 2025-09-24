// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title Compliance Internal Interface
 * @notice Internal interface defining events and errors for compliance operations
 * @dev This interface contains events and errors emitted during compliance management
 */
interface IComplianceInternal {
    /**
     * @notice Emitted when a token contract is bound to the compliance module
     * @param token The address of the token contract that was bound
     */
    event TokenBound(address indexed token);

    /**
     * @notice Emitted when a token contract is unbound from the compliance module
     * @param token The address of the token contract that was unbound
     */
    event TokenUnbound(address indexed token);

    /**
     * @notice Error thrown when trying to bind a token that is already bound
     * @param token The address of the token that is already bound
     */
    error TokenAlreadyBound(address token);

    /**
     * @notice Error thrown when trying to operate on a token that is not bound
     * @param token The address of the token that is not bound
     */
    error TokenNotBound(address token);

    /**
     * @notice Error thrown when an invalid token address is provided
     * @param token The invalid token address
     */
    error InvalidTokenAddress(address token);

    /**
     * @notice Error thrown when a transfer fails compliance checks
     * @param from The sender address
     * @param to The receiver address
     * @param amount The transfer amount that failed compliance
     */
    error ComplianceCheckFailed(address from, address to, uint256 amount);
}
