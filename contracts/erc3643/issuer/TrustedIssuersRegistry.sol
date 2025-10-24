// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ITrustedIssuersRegistry.sol";
import "./TrustedIssuersRegistryInternal.sol";

contract TrustedIssuersRegistry is
    ITrustedIssuersRegistry,
    TrustedIssuersRegistryInternal
{
    // Setters
    function addTrustedIssuer(
        IClaimIssuer _trustedIssuer,
        uint256[] calldata _claimTopics
    ) external override {
        _addTrustedIssuer(_trustedIssuer, _claimTopics);
    }

    function removeTrustedIssuer(
        IClaimIssuer _trustedIssuer
    ) external override {
        _removeTrustedIssuer(_trustedIssuer);
    }

    function updateIssuerClaimTopics(
        IClaimIssuer _trustedIssuer,
        uint256[] calldata _claimTopics
    ) external override {
        _updateIssuerClaimTopics(_trustedIssuer, _claimTopics);
    }

    // Getters
    function getTrustedIssuers()
        external
        view
        override
        returns (IClaimIssuer[] memory)
    {
        return _getTrustedIssuers();
    }

    function isTrustedIssuer(
        address _issuer
    ) external view override returns (bool) {
        return _isTrustedIssuer(_issuer);
    }

    function getTrustedIssuerClaimTopics(
        IClaimIssuer _trustedIssuer
    ) external view override returns (uint256[] memory) {
        return _getTrustedIssuerClaimTopics(_trustedIssuer);
    }

    function getTrustedIssuersForClaimTopic(
        uint256 claimTopic
    ) external view override returns (IClaimIssuer[] memory) {
        return _getTrustedIssuersForClaimTopic(claimTopic);
    }

    function hasClaimTopic(
        address _issuer,
        uint256 _claimTopic
    ) external view override returns (bool) {
        return _hasClaimTopic(_issuer, _claimTopic);
    }
}
