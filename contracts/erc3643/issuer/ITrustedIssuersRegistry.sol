// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ITrustedIssuersRegistryInternal.sol";

/**
 * @title Trusted Issuers Registry Interface
 * @notice Interface for managing trusted claim issuers in the ERC3643 ecosystem
 * @dev This interface extends ITrustedIssuersRegistryInternal and provides external functions for issuer management
 * @dev Note: ERC3643 specification uses IClaimIssuer interface, but for package compatibility we use address
 * @dev In a full ERC3643 implementation, these would be IClaimIssuer types
 */
interface ITrustedIssuersRegistry is ITrustedIssuersRegistryInternal {
    /**
     * @notice Adds a new trusted issuer with specified claim topics
     * @dev Only the contract owner can call this function
     * @param _trustedIssuer The address of the issuer to add as trusted
     * @param _claimTopics Array of claim topic IDs that this issuer can verify
     */
    function addTrustedIssuer(address _trustedIssuer, uint256[] calldata _claimTopics) external;
    
    /**
     * @notice Removes a trusted issuer from the registry
     * @dev Only the contract owner can call this function
     * @param _trustedIssuer The address of the issuer to remove
     */
    function removeTrustedIssuer(address _trustedIssuer) external;
    
    /**
     * @notice Updates the claim topics for an existing trusted issuer
     * @dev Only the contract owner can call this function
     * @param _trustedIssuer The address of the issuer to update
     * @param _claimTopics New array of claim topic IDs for this issuer
     */
    function updateIssuerClaimTopics(address _trustedIssuer, uint256[] calldata _claimTopics) external;

    /**
     * @notice Returns all trusted issuer addresses
     * @return address[] Array of all trusted issuer addresses
     */
    function getTrustedIssuers() external view returns (address[] memory);
    
    /**
     * @notice Checks if an address is a trusted issuer
     * @param _issuer The address to check
     * @return bool True if the address is a trusted issuer, false otherwise
     */
    function isTrustedIssuer(address _issuer) external view returns (bool);
    
    /**
     * @notice Returns the claim topics that a trusted issuer can verify
     * @param _trustedIssuer The address of the trusted issuer
     * @return uint256[] Array of claim topic IDs
     */
    function getTrustedIssuerClaimTopics(address _trustedIssuer) external view returns (uint256[] memory);
    
    /**
     * @notice Returns all trusted issuers that can verify a specific claim topic
     * @param claimTopic The claim topic ID to query
     * @return address[] Array of trusted issuer addresses
     */
    function getTrustedIssuersForClaimTopic(uint256 claimTopic) external view returns (address[] memory);
    
    /**
     * @notice Checks if a trusted issuer can verify a specific claim topic
     * @param _issuer The address of the issuer to check
     * @param _claimTopic The claim topic ID to check
     * @return bool True if the issuer can verify the claim topic, false otherwise
     */
    function hasClaimTopic(address _issuer, uint256 _claimTopic) external view returns (bool);
}