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
        IClaimIssuer _trustedIssuer,
        uint256[] calldata _claimTopics
    ) internal onlyOwner {
        TrustedIssuersRegistryStorage.Layout
            storage l = TrustedIssuersRegistryStorage.layout();

        if (address(_trustedIssuer) == address(0)) {
            revert InvalidIssuerAddress(address(_trustedIssuer));
        }
        if (_claimTopics.length == 0) {
            revert EmptyClaimTopics();
        }
        if (l.trustedIssuers[address(_trustedIssuer)].exists) {
            revert IssuerAlreadyTrusted(address(_trustedIssuer));
        }

        // Add issuer to the list
        l.issuerIndex[address(_trustedIssuer)] = l.issuersList.length;
        l.issuersList.push(_trustedIssuer);

        // Store issuer data
        l.trustedIssuers[address(_trustedIssuer)] = TrustedIssuer({
            exists: true,
            claimTopics: _claimTopics
        });

        // Update claim topic mappings
        for (uint256 i = 0; i < _claimTopics.length; i++) {
            uint256 topic = _claimTopics[i];
            l.issuerTopicIndex[topic][address(_trustedIssuer)] = l
                .issuersForClaimTopic[topic]
                .length;
            l.issuersForClaimTopic[topic].push(_trustedIssuer);
        }

        emit TrustedIssuerAdded(IClaimIssuer(_trustedIssuer), _claimTopics);
    }

    function _removeTrustedIssuer(
        IClaimIssuer _trustedIssuer
    ) internal onlyOwner {
        TrustedIssuersRegistryStorage.Layout
            storage l = TrustedIssuersRegistryStorage.layout();

        if (!l.trustedIssuers[address(_trustedIssuer)].exists) {
            revert IssuerNotTrusted(address(_trustedIssuer));
        }

        // Remove from claim topic mappings
        uint256[] memory topics = l
            .trustedIssuers[address(_trustedIssuer)]
            .claimTopics;
        for (uint256 i = 0; i < topics.length; i++) {
            uint256 topic = topics[i];
            uint256 topicIndex = l.issuerTopicIndex[topic][
                address(_trustedIssuer)
            ];
            uint256 topicLastIndex = l.issuersForClaimTopic[topic].length - 1;

            if (topicIndex != topicLastIndex) {
                IClaimIssuer lastIssuer = l.issuersForClaimTopic[topic][
                    topicLastIndex
                ];
                l.issuersForClaimTopic[topic][topicIndex] = lastIssuer;
                l.issuerTopicIndex[topic][address(lastIssuer)] = topicIndex;
            }

            l.issuersForClaimTopic[topic].pop();
            delete l.issuerTopicIndex[topic][address(_trustedIssuer)];
        }

        // Remove from issuers list
        uint256 index = l.issuerIndex[address(_trustedIssuer)];
        uint256 lastIndex = l.issuersList.length - 1;

        if (index != lastIndex) {
            IClaimIssuer lastIssuer = l.issuersList[lastIndex];
            l.issuersList[index] = lastIssuer;
            l.issuerIndex[address(lastIssuer)] = index;
        }

        l.issuersList.pop();
        delete l.issuerIndex[address(_trustedIssuer)];
        delete l.trustedIssuers[address(_trustedIssuer)];

        emit TrustedIssuerRemoved(IClaimIssuer(_trustedIssuer));
    }

    function _updateIssuerClaimTopics(
        IClaimIssuer _trustedIssuer,
        uint256[] calldata _claimTopics
    ) internal onlyOwner {
        TrustedIssuersRegistryStorage.Layout
            storage l = TrustedIssuersRegistryStorage.layout();

        if (!l.trustedIssuers[address(_trustedIssuer)].exists) {
            revert IssuerNotTrusted(address(_trustedIssuer));
        }
        if (_claimTopics.length == 0) {
            revert EmptyClaimTopics();
        }

        // Remove old claim topic mappings
        uint256[] memory oldTopics = l
            .trustedIssuers[address(_trustedIssuer)]
            .claimTopics;
        for (uint256 i = 0; i < oldTopics.length; i++) {
            uint256 topic = oldTopics[i];
            uint256 topicIndex = l.issuerTopicIndex[topic][
                address(_trustedIssuer)
            ];
            uint256 lastIndex = l.issuersForClaimTopic[topic].length - 1;

            if (topicIndex != lastIndex) {
                IClaimIssuer lastIssuer = l.issuersForClaimTopic[topic][
                    lastIndex
                ];
                l.issuersForClaimTopic[topic][topicIndex] = lastIssuer;
                l.issuerTopicIndex[topic][address(lastIssuer)] = topicIndex;
            }

            l.issuersForClaimTopic[topic].pop();
            delete l.issuerTopicIndex[topic][address(_trustedIssuer)];
        }

        // Update with new claim topics
        l.trustedIssuers[address(_trustedIssuer)].claimTopics = _claimTopics;

        // Add new claim topic mappings
        for (uint256 i = 0; i < _claimTopics.length; i++) {
            uint256 topic = _claimTopics[i];
            l.issuerTopicIndex[topic][address(_trustedIssuer)] = l
                .issuersForClaimTopic[topic]
                .length;
            l.issuersForClaimTopic[topic].push(_trustedIssuer);
        }

        emit ClaimTopicsUpdated(IClaimIssuer(_trustedIssuer), _claimTopics);
    }

    function _getTrustedIssuers()
        internal
        view
        returns (IClaimIssuer[] memory)
    {
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
        IClaimIssuer _trustedIssuer
    ) internal view returns (uint256[] memory) {
        TrustedIssuersRegistryStorage.Layout
            storage l = TrustedIssuersRegistryStorage.layout();
        return l.trustedIssuers[address(_trustedIssuer)].claimTopics;
    }

    function _getTrustedIssuersForClaimTopic(
        uint256 claimTopic
    ) internal view returns (IClaimIssuer[] memory) {
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
