// import { expect , assert} from 'chai';
// import hre from 'hardhat';
// import {getContract} from 'viem';
// import { readFileSync } from 'fs';
// import { join } from 'path';
// import { FacetCutAction } from '../scripts/libraries/diamond';
// import { deployDiamond } from '../scripts/deployDiamond';
// import { getSelectors, removeSelectors, findAddressPositionInFacets } from '../scripts/libraries/diamond';
// // import { diamondCutFacetAbi, diamondLoupeFacetAbi, ownershipFacetAbi } from './path/to/your/abis';

// describe('DiamondTest', function () {
//  let diamondAddress: string;
//  let diamondCutFacet: any; // Replace with the actual type of your contract
//  let diamondLoupeFacet: any; // Replace with the actual type of your contract
//  let ownershipFacet: any; // Replace with the actual type of your contract
//  let tx: Promise<any>; // Replace with the actual type of your transaction
//  let receipt: any; // Replace with the actual type of your receipt
//  let result: any[];
//  const addresses: string[] = [];

//  before(async function () {
//     // Load ABIs
//     const diamondCutFacetAbi = JSON.parse(readFileSync(join(__dirname, '../artifacts/contracts/facets/DiamondCutFacet.sol/DiamondCutFacet.json'), 'utf8')).abi;  

//     const diamondLoupeFacetAbi = JSON.parse(readFileSync(join(__dirname, '../artifacts/contracts/facets/DiamondLoupeFacet.sol/DiamondLoupeFacet.json'), 'utf8')).abi;  

//     const ownershipFacetAbi = JSON.parse(readFileSync(join(__dirname, '../artifacts/contracts/facets/OwnershipFacet.sol/OwnershipFacet.json'), 'utf8')).abi;  
//     // Deploy the diamond contract without any facets
//     diamondAddress = await deployDiamond([]);

//     // Retrieve contract instances
//     diamondCutFacet =  getContract({
//       address: diamondAddress as `0x${string}`,
//       abi: diamondCutFacetAbi, 
//     });
//     diamondLoupeFacet = getContract({
//       address: diamondAddress as `0x${string}`,
//       abi: diamondLoupeFacetAbi, 
//     });
//     ownershipFacet = getContract({
//       address: diamondAddress as `0x${string}`,
//       abi: ownershipFacetAbi, 
//     });
//  });


//  it('should deploy the diamond contract successfully', async function () {
//   expect(diamondAddress).to.not.be.empty;
// });

// it('should have the correct facets', async () => {
//   const selectors = getSelectors(diamondCutFacet);
//   const facetAddresses = selectors.map((selector) => diamondLoupeFacet.facetAddress(selector));
//   assert.equal(facetAddresses.length, 3, 'Expected 3 facets');
// });



// it('should allow adding a new facet', async function () {
//   // Example: Add a new facet
//   // You'll need to implement the logic for adding a facet, including deploying the new facet contract and calling diamondCutFacet.diamondCut
// });

// it('should allow replacing an existing facet', async function () {
//   // Example: Replace an existing facet
//   // Similar to adding a new facet, but you'll need to specify the facet to replace
// });

// it('should allow removing a facet', async function () {
//   // Example: Remove a facet
//   // You'll need to specify the facet to remove and call diamondCutFacet.diamondCut with the appropriate action
// });

 
// });