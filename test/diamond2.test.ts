// import { expect } from "chai";
// import hre from "hardhat";
// import { getContract } from "viem";
// import { deployDiamond } from "../scripts/deployDiamond"; 
// import { readFileSync } from "fs";
// import { join } from "path";
// import mainnet  from 'viem';
// import { publicClient, walletClient } from "../clients/client";

// describe("Diamond Contract Test", function () {
//     let diamondInstance: any;
//     let diamondCutFacet: any;
//     let diamondLoupeFacet: any;
//     let ownershipFacet: any;
//     let erc3643Facet: any;
//     let walletClient: any;

//     beforeEach(async function () {
//         // Deploy the Diamond contract and its facets
//         const {
//             diamondInstance: diamondInstanceValue,
//             diamondCutFacet: diamondCutFacetValue,
//             diamondLoupeFacet: diamondLoupeFacetValue,
//             ownershipFacet: ownershipFacetValue,
//             erc3643Facet: erc3643FacetValue,
//             walletClient: walletClientValue,
//         } = await deployDiamond();

//         diamondInstance = diamondInstanceValue;
//         diamondCutFacet = diamondCutFacetValue;
//         diamondLoupeFacet = diamondLoupeFacetValue;
//         ownershipFacet = ownershipFacetValue;
//         erc3643Facet = erc3643FacetValue;
//         walletClient = walletClientValue;
//     });

//     it("should deploy the diamond contract successfully", async function () {
//         expect(diamondInstance).to.not.be.undefined;
//         expect(diamondInstance.address).to.not.be.empty;
//     });

//     it("should add a new facet successfully", async function () {
//         // Example: Add a new facet to the diamond
//         // This test case would involve deploying a new facet contract,
//         // preparing a facet cut to add it to the diamond, and then
//         // calling the diamondCutFacet's diamondCut function to add the new facet.
//         // The specifics of this test case would depend on the details of your facet contracts.
//     });

//     it("should remove a facet successfully", async function () {
//         // Example: Remove an existing facet from the diamond
//         // This test case would involve preparing a facet cut to remove an existing facet
//         // and then calling the diamondCutFacet's diamondCut function to remove the facet.
//         // The specifics of this test case would depend on the details of your facet contracts.
//     });

//     // Add more test cases as needed to cover the functionality of your Diamond contract
// });