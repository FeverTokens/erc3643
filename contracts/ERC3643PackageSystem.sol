// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IDiamondBase, DiamondBase} from "./diamond/base/DiamondBase.sol";
import {FacetCutAction, FacetCut, IPackageController, PackageControllerInternal} from "./diamond/control/PackageController.sol";
import {IPackageViewer} from "./diamond/view/IPackageViewer.sol";
import {IInitializable} from "./initializable/IInitializable.sol";
import {IAccessControl} from "./access/rbac/IAccessControl.sol";
import {IAgentRole} from "./erc3643/agent/IAgentRole.sol";
import {Proxy} from "./diamond/proxy/Proxy.sol";

/**
 * @title Diamond proxy reference implementation inspired from SolidState
 */
contract ERC3643PackageSystem is
    IDiamondBase,
    DiamondBase,
    PackageControllerInternal
{
    constructor(
        address _packageControllerAddress,
        address _packageViewerAddress,
        address _initializerPackageAddress,
        address _accessControlPackageAddress,
        address owner
    ) {
        // diamond cuts
        FacetCut[] memory facetCuts = new FacetCut[](4);

        // register PackageController
        bytes4[] memory packageControllerSelectors = new bytes4[](1);
        packageControllerSelectors[0] = IPackageController.diamondCut.selector;

        facetCuts[0] = FacetCut({
            target: _packageControllerAddress,
            action: FacetCutAction.ADD,
            selectors: packageControllerSelectors
        });

        // register PackageViewer
        bytes4[] memory packageViewerSelectors = new bytes4[](4);
        packageViewerSelectors[0] = IPackageViewer.facets.selector;
        packageViewerSelectors[1] = IPackageViewer
            .facetFunctionSelectors
            .selector;
        packageViewerSelectors[2] = IPackageViewer.facetAddresses.selector;
        packageViewerSelectors[3] = IPackageViewer.facetAddress.selector;

        facetCuts[1] = FacetCut({
            target: _packageViewerAddress,
            action: FacetCutAction.ADD,
            selectors: packageViewerSelectors
        });

        // register Initializer
        bytes4[] memory initializerSelectors = new bytes4[](1);
        initializerSelectors[0] = IInitializable.getInitializing.selector;

        facetCuts[2] = FacetCut({
            target: _initializerPackageAddress,
            action: FacetCutAction.ADD,
            selectors: initializerSelectors
        });

        // register AgentRole
        bytes4[] memory accessControlSelectors = new bytes4[](3);
        accessControlSelectors[0] = IAgentRole.addAgent.selector;
        accessControlSelectors[1] = IAgentRole.removeAgent.selector;
        accessControlSelectors[2] = IAgentRole.isAgent.selector;

        facetCuts[3] = FacetCut({
            target: _accessControlPackageAddress,
            action: FacetCutAction.ADD,
            selectors: accessControlSelectors
        });

        __PackageController_init(owner);

        _diamondCut(facetCuts, address(0), bytes(""));
    }

    receive() external payable {}
}
