// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ITrustedIssuersRegistryInternal.sol";
import "./TrustedIssuersRegistryStorage.sol";
import "../agent/AgentRoleInternal.sol";

abstract contract TrustedIssuersRegistryInternal is
    ITrustedIssuersRegistryInternal,
    AgentRoleInternal
{
    using TrustedIssuersRegistryStorage for TrustedIssuersRegistryStorage.Layout;

    function _addTrustedIssuer(
        address _trustedIssuer,
        uint256[] calldata _claimTopics
    ) internal onlyOwner {
        TrustedIssuersRegistryStorage.Layout
            storage l = TrustedIssuersRegistryStorage.layout();

        if (_trustedIssuer == address(0)) {
            revert InvalidIssuerAddress(_trustedIssuer);
        }
        if (_claimTopics.length == 0) {
            revert EmptyClaimTopics();
        }
        if (l.trustedIssuers[_trustedIssuer].exists) {
            revert IssuerAlreadyTrusted(_trustedIssuer);
        }

        // Add issuer to the list
        l.issuerIndex[_trustedIssuer] = l.issuersList.length;
        l.issuersList.push(_trustedIssuer);

        // Store issuer data
        l.trustedIssuers[_trustedIssuer] = TrustedIssuer({
            exists: true,
            claimTopics: _claimTopics
        });

        // Update claim topic mappings
        for (uint256 i = 0; i < _claimTopics.length; i++) {
            uint256 topic = _claimTopics[i];
            l.issuerTopicIndex[topic][_trustedIssuer] = l
                .issuersForClaimTopic[topic]
                .length;
            l.issuersForClaimTopic[topic].push(_trustedIssuer);
        }

        emit TrustedIssuerAdded(_trustedIssuer, _claimTopics);
    }

    function _removeTrustedIssuer(address _trustedIssuer) internal onlyOwner {
        TrustedIssuersRegistryStorage.Layout
            storage l = TrustedIssuersRegistryStorage.layout();

        if (!l.trustedIssuers[_trustedIssuer].exists) {
            revert IssuerNotTrusted(_trustedIssuer);
        }

        // Remove from claim topic mappings
        uint256[] memory topics = l.trustedIssuers[_trustedIssuer].claimTopics;
        for (uint256 i = 0; i < topics.length; i++) {
            uint256 topic = topics[i];
            uint256 topicIndex = l.issuerTopicIndex[topic][_trustedIssuer];
            uint256 topicLastIndex = l.issuersForClaimTopic[topic].length - 1;

            if (topicIndex != topicLastIndex) {
                address lastIssuer = l.issuersForClaimTopic[topic][
                    topicLastIndex
                ];
                l.issuersForClaimTopic[topic][topicIndex] = lastIssuer;
                l.issuerTopicIndex[topic][lastIssuer] = topicIndex;
            }

            l.issuersForClaimTopic[topic].pop();
            delete l.issuerTopicIndex[topic][_trustedIssuer];
        }

        // Remove from issuers list
        uint256 index = l.issuerIndex[_trustedIssuer];
        uint256 lastIndex = l.issuersList.length - 1;

        if (index != lastIndex) {
            address lastIssuer = l.issuersList[lastIndex];
            l.issuersList[index] = lastIssuer;
            l.issuerIndex[lastIssuer] = index;
        }

        l.issuersList.pop();
        delete l.issuerIndex[_trustedIssuer];
        delete l.trustedIssuers[_trustedIssuer];

        emit TrustedIssuerRemoved(_trustedIssuer);
    }

    function _updateIssuerClaimTopics(
        address _trustedIssuer,
        uint256[] calldata _claimTopics
    ) internal onlyOwner {
        TrustedIssuersRegistryStorage.Layout
            storage l = TrustedIssuersRegistryStorage.layout();

        if (!l.trustedIssuers[_trustedIssuer].exists) {
            revert IssuerNotTrusted(_trustedIssuer);
        }
        if (_claimTopics.length == 0) {
            revert EmptyClaimTopics();
        }

        // Remove old claim topic mappings
        uint256[] memory oldTopics = l
            .trustedIssuers[_trustedIssuer]
            .claimTopics;
        for (uint256 i = 0; i < oldTopics.length; i++) {
            uint256 topic = oldTopics[i];
            uint256 topicIndex = l.issuerTopicIndex[topic][_trustedIssuer];
            uint256 lastIndex = l.issuersForClaimTopic[topic].length - 1;

            if (topicIndex != lastIndex) {
                address lastIssuer = l.issuersForClaimTopic[topic][lastIndex];
                l.issuersForClaimTopic[topic][topicIndex] = lastIssuer;
                l.issuerTopicIndex[topic][lastIssuer] = topicIndex;
            }

            l.issuersForClaimTopic[topic].pop();
            delete l.issuerTopicIndex[topic][_trustedIssuer];
        }

        // Update with new claim topics
        l.trustedIssuers[_trustedIssuer].claimTopics = _claimTopics;

        // Add new claim topic mappings
        for (uint256 i = 0; i < _claimTopics.length; i++) {
            uint256 topic = _claimTopics[i];
            l.issuerTopicIndex[topic][_trustedIssuer] = l
                .issuersForClaimTopic[topic]
                .length;
            l.issuersForClaimTopic[topic].push(_trustedIssuer);
        }

        emit ClaimTopicsUpdated(_trustedIssuer, _claimTopics);
    }

    function _getTrustedIssuers() internal view returns (address[] memory) {
        TrustedIssuersRegistryStorage.Layout
            storage l = TrustedIssuersRegistryStorage.layout();
        return l.issuersList;
    }

    function _isTrustedIssuer(address _issuer) internal view returns (bool) {
        TrustedIssuersRegistryStorage.Layout
            storage l = TrustedIssuersRegistryStorage.layout();
        return l.trustedIssuers[_issuer].exists;
    }

    function _getTrustedIssuerClaimTopics(
        address _trustedIssuer
    ) internal view returns (uint256[] memory) {
        TrustedIssuersRegistryStorage.Layout
            storage l = TrustedIssuersRegistryStorage.layout();
        return l.trustedIssuers[_trustedIssuer].claimTopics;
    }

    function _getTrustedIssuersForClaimTopic(
        uint256 claimTopic
    ) internal view returns (address[] memory) {
        TrustedIssuersRegistryStorage.Layout
            storage l = TrustedIssuersRegistryStorage.layout();
        return l.issuersForClaimTopic[claimTopic];
    }

    function _hasClaimTopic(
        address _issuer,
        uint256 _claimTopic
    ) internal view returns (bool) {
        TrustedIssuersRegistryStorage.Layout
            storage l = TrustedIssuersRegistryStorage.layout();

        if (!l.trustedIssuers[_issuer].exists) {
            return false;
        }

        uint256[] memory topics = l.trustedIssuers[_issuer].claimTopics;
        for (uint256 i = 0; i < topics.length; i++) {
            if (topics[i] == _claimTopic) {
                return true;
            }
        }

        return false;
    }
}
