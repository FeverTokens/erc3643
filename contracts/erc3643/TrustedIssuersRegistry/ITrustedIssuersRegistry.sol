// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ITrustedIssuersRegistryInternal.sol";

// Note: ERC3643 specification uses IClaimIssuer interface, but for package compatibility we use address
// In a full ERC3643 implementation, these would be IClaimIssuer types
interface ITrustedIssuersRegistry is ITrustedIssuersRegistryInternal {
    // Setters
    function addTrustedIssuer(address _trustedIssuer, uint256[] calldata _claimTopics) external;
    function removeTrustedIssuer(address _trustedIssuer) external;
    function updateIssuerClaimTopics(address _trustedIssuer, uint256[] calldata _claimTopics) external;

    // Getters
    function getTrustedIssuers() external view returns (address[] memory);
    function isTrustedIssuer(address _issuer) external view returns (bool);
    function getTrustedIssuerClaimTopics(address _trustedIssuer) external view returns (uint256[] memory);
    function getTrustedIssuersForClaimTopic(uint256 claimTopic) external view returns (address[] memory);
    function hasClaimTopic(address _issuer, uint256 _claimTopic) external view returns (bool);
}