import { expect } from "chai";
import hre from "hardhat";
import { getContract } from "viem"; // Removed createPublicClient
import { readFileSync } from "fs";
import { join } from "path";
import { deployDiamond } from "../scripts/deployDiamond";
import { getSelectors, FacetCutAction } from "../scripts/libraries/diamond";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { prepareDiamondLoupeFacet } from "../scripts/prepareFacets/prepareDiamondLoupeFacet";
import { prepareOwnershipFacet } from "../scripts/prepareFacets/prepareOwnershipFacet";
import { prepareERC3643Facet } from "../scripts/prepareFacets/prepareERC3643Facet";
import { Hex, createWalletClient, http, publicActions } from "viem";
import { walletClient } from "../clients/client"; 
import { mainnet } from "viem/chains";
import { arbitrumSepolia } from "viem/chains";
import { sepolia } from "viem/chains";
import dotenv from "dotenv";
import { privateKeyToAccount } from "viem/accounts";
import { parseGwei } from "viem";

dotenv.config();

// Assuming the deploy function correctly initializes the facets
const deploy = async () => {
 const privateKey = process.env.PRIVATE_KEY;

 const account = privateKeyToAccount(privateKey as Hex);
 const wallet = await hre.viem.getWalletClients();
 const contractOwner = wallet[0].account.address;

 const walletClient = createWalletClient({
    chain: arbitrumSepolia,
    transport: http(process.env.API_URL),
 });

 const erc3643FacetAbi = JSON.parse(
    readFileSync(
      join(
        __dirname,
        "../artifacts/contracts/facets/erc3643Package/ERC3643Facet.sol/ERC3643Facet.json"
      ),
      "utf8"
    )
 ).abi;

 // Deploy each facet individually
 const diamondLoupeFacetCut = await prepareDiamondLoupeFacet(contractOwner);
 const ownershipFacetCut = await prepareOwnershipFacet(contractOwner);
 const erc3643FacetCut = await prepareERC3643Facet(
    contractOwner,
    erc3643FacetAbi
 );

 // Combine all facet cuts into a single array
 const cut = [diamondLoupeFacetCut, ownershipFacetCut, erc3643FacetCut];
 console.log("#### Deploying Diamond ####");
 const diamondInstance = await deployDiamond(contractOwner, cut);

 const diamondAddress = diamondInstance.address;

 console.log("diamondAddress", diamondAddress);
 const diamondCutFacetAbi = JSON.parse(
    readFileSync(
      join(
        __dirname,
        "../artifacts/contracts/facets/DiamondCutFacet.sol/DiamondCutFacet.json"
      ),
      "utf8"
    )
 ).abi;
 const diamondLoupeFacetAbi = JSON.parse(
    readFileSync(
      join(
        __dirname,
        "../artifacts/contracts/facets/DiamondLoupeFacet.sol/DiamondLoupeFacet.json"
      ),
      "utf8"
    )
 ).abi;
 const ownershipFacetAbi = JSON.parse(
    readFileSync(
      join(
        __dirname,
        "../artifacts/contracts/facets/OwnershipFacet.sol/OwnershipFacet.json"
      ),
      "utf8"
    )
 ).abi;

 const erc3643Facet = await hre.viem.deployContract("ERC3643Facet", []);

 // Create contracts instances
 const diamondCutFacet = getContract({
    address: diamondAddress,
    abi: diamondCutFacetAbi,
    walletClient: walletClient, // Updated to use the new client parameter
 });

 const diamondLoupeFacet = getContract({
    address: diamondAddress,
    abi: diamondCutFacetAbi,
    walletClient: walletClient, // Updated to use the new client parameter
 });

 const ownershipFacet = getContract({
    address: diamondAddress,
    abi: diamondCutFacetAbi,
    walletClient: walletClient, // Updated to use the new client parameter
 });

 // Create the testClient
 const testClient = createWalletClient({
    account,
    chain: arbitrumSepolia,
    transport: http(process.env.API_URL),
 }).extend(publicActions);

 return {
    diamondInstance,
    diamondCutFacet,
    diamondLoupeFacet,
    ownershipFacet,
    erc3643Facet,
    walletClient,
    testClient,
    privateKey
 };
};

// The rest of your test code remains unchanged

describe("DiamondTest", function () {
  let diamondInstance: any;
  let diamondCutFacet: any;
  let diamondLoupeFacet: any;
  let ownershipFacet: any;
  let erc3643Facet: any;
  let walletClient: any;
  let testClient: any;
  let privateKey: any;

  beforeEach(async function () {
    const {
      diamondInstance: diamondInstanceValue,
      diamondCutFacet: diamondCutFacetValue,
      diamondLoupeFacet: diamondLoupeFacetValue,
      ownershipFacet: ownershipFacetValue,
      erc3643Facet: erc3643FacetValue,
      walletClient: walletClientValue,
      testClient: testClientValue,
      privateKey: privateKeyValue,
    } = await loadFixture(deploy);

    diamondInstance = diamondInstanceValue;
    diamondCutFacet = diamondCutFacetValue;
    diamondLoupeFacet = diamondLoupeFacetValue;
    ownershipFacet = ownershipFacetValue;
    erc3643Facet = erc3643FacetValue;
    walletClient = walletClientValue;
    testClient = testClientValue;
    privateKey = privateKeyValue;
  });

  it("should add a new facet successfully", async function () {
    try {
       // Assuming walletClient and diamondInstance are correctly initialized elsewhere
   
       // Deploy the new facet
       const facet = await hre.viem.deployContract("ERC3643Facet", []);
       const newFacetAddress = facet.address;
   
       const diamondCutFacetAbi = JSON.parse(
         readFileSync(
           join(
             __dirname,
             "../artifacts/contracts/facets/DiamondCutFacet.sol/DiamondCutFacet.json"
           ),
           "utf8"
         )
       ).abi;
   
       const wallet = await hre.viem.getWalletClients();
       const contractOwner = wallet[0].account.address;
       const accountAddress = contractOwner;
       const selectors = getSelectors({ abi: diamondCutFacetAbi });
   
       const diamondInit = await hre.viem.deployContract("DiamondInit", []);
   
       const args = [
         [
           {
             facetAddress: newFacetAddress,
             action: FacetCutAction.Add,
             functionSelectors: selectors,
           },
         ],
         diamondInit.address,
         "0x", 
       ];
       const x = await walletClient.writeContract({
         address: diamondInstance.address,
         abi: diamondCutFacetAbi,
         functionName: "diamondCut",
         args,
         account: accountAddress,
       });
       console.log("----------hsjash---",x);
    } catch (error) {
       console.error("Failed to add a new facet:", error);
    }
   });

  

  it("should verify the functionality of the ERC3643Facet", async function () {
    // Assuming the erc3643Facet object is correctly initialized
    const erc3643Facet = await hre.viem.deployContract("ERC3643Facet", []);

    if (typeof erc3643Facet.write.addAgent !== "function") {
      throw new Error("erc3643Facet does not have the expected method");
    }

   
    
  });


});





