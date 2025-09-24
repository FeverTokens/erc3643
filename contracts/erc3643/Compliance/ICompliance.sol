// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IComplianceInternal.sol";

/**
 * @title Compliance Interface
 * @notice Interface for managing token compliance rules and transfer validations
 * @dev This interface extends IComplianceInternal and provides external functions for compliance management
 */
interface ICompliance is IComplianceInternal {
    /**
     * @notice Binds a token contract to this compliance module
     * @dev Only the contract owner can call this function. One compliance can only be bound to one token.
     * @param _token The address of the token contract to bind
     */
    function bindToken(address _token) external;
    
    /**
     * @notice Unbinds the currently bound token from this compliance module
     * @dev Only the contract owner can call this function
     * @param _token The address of the token contract to unbind (must match currently bound token)
     */
    function unbindToken(address _token) external;

    /**
     * @notice Checks if a specific token is bound to this compliance module
     * @param _token The address of the token contract to check
     * @return bool True if the token is bound to this compliance module, false otherwise
     */
    function isTokenBound(address _token) external view returns (bool);
    
    /**
     * @notice Returns the address of the currently bound token
     * @return address The address of the bound token contract, or zero address if none bound
     */
    function getTokenBound() external view returns (address);

    /**
     * @notice Checks if a token transfer complies with all compliance rules
     * @dev This function should be called before executing a transfer
     * @param _from The address sending the tokens
     * @param _to The address receiving the tokens
     * @param _amount The amount of tokens to transfer
     * @return bool True if the transfer is compliant, false otherwise
     */
    function canTransfer(address _from, address _to, uint256 _amount) external view returns (bool);
    
    /**
     * @notice Updates compliance state after a successful token transfer
     * @dev This function should be called after executing a transfer to update balances and counts
     * @param _from The address that sent the tokens
     * @param _to The address that received the tokens
     * @param _amount The amount of tokens that were transferred
     */
    function transferred(address _from, address _to, uint256 _amount) external;
    
    /**
     * @notice Updates compliance state after token creation (minting)
     * @dev This function should be called after minting tokens to update balances and counts
     * @param _to The address that received the newly created tokens
     * @param _amount The amount of tokens that were created
     */
    function created(address _to, uint256 _amount) external;
    
    /**
     * @notice Updates compliance state after token destruction (burning)
     * @dev This function should be called after burning tokens to update balances and counts
     * @param _from The address that had tokens burned
     * @param _amount The amount of tokens that were destroyed
     */
    function destroyed(address _from, uint256 _amount) external;
}