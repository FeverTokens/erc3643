import hre from "hardhat";
import { prepareDiamondLoupeFacet } from "../scripts/prepareFacets/prepareDiamondLoupeFacet";
import { prepareOwnershipFacet } from "../scripts/prepareFacets/prepareOwnershipFacet";
import { deployDiamond } from "../scripts/deployDiamond";
import { expect } from "chai";
import { getSelectors, FacetCutAction } from "../scripts/libraries/diamond";
import { readFileSync } from "fs";
import { join } from "path";
import { Hex, createWalletClient, http, publicActions } from "viem";
import { arbitrumSepolia } from "viem/chains";
import { privateKeyToAccount } from "viem/accounts";
import { config } from "dotenv";
import { prepareAgentManagementFacet } from "../scripts/prepareFacets/prepareAgentManagementFacet";
import { prepareComplianceAndOnChainIdTokenManagementFacet } from "../scripts/prepareFacets/prepareComplianceAndOnChainIdTokenManagementFacet";
import { prepareTokenManagementFacet } from "../scripts/prepareFacets/prepareTokenManagementFacet";
import { prepareTokenOperationsFacet } from "../scripts/prepareFacets/prepareTokenOperationsFacet";
// import { ftganacheConfig } from "../ftganacheConfig";
config();

describe("Deployment Scripts Test", function () {
  // Initial test setup
  let diamond: any;
  let contractOwner: string;
  let testClient: any;
  let account: any;

  const AgentManagementFacetAbi = JSON.parse(readFileSync(join(__dirname,"../artifacts/contracts/Packages/AgentManagement/AgentManagement.sol/AgentManagement.json",),"utf8",),
      ).abi;
    
  const ComplianceAndOnChainIdTokenManagementFacetAbi = JSON.parse(readFileSync(join(__dirname,"../artifacts/contracts/Packages/ComplianceAndOnChainIdTokenManagement/ComplianceOnChainId.sol/ComplianceOnChainId.json",),"utf8",),
      ).abi;
    
  const TokenManagementFacetAbi = JSON.parse(readFileSync(join(__dirname,"../artifacts/contracts/Packages/TokenManagement/TokenManagement.sol/TokenManagement.json",),"utf8",),
     ).abi;
    
  const TokenOperationsFacetAbi = JSON.parse(readFileSync(join(__dirname,	"../artifacts/contracts/Packages/TokensOperations/TokenOperation.sol/TokenOperation.json",),"utf8",),
      ).abi;

  before(async function () {
    const accounts = await hre.viem.getWalletClients();
    contractOwner = accounts[0].account.address;

    const diamondLoupeFacetCut = await prepareDiamondLoupeFacet(contractOwner);
    const ownershipFacetCut = await prepareOwnershipFacet(contractOwner);
    const agentManagementCut = await prepareAgentManagementFacet(contractOwner,AgentManagementFacetAbi);
    const complianceCut = await prepareComplianceAndOnChainIdTokenManagementFacet(contractOwner,ComplianceAndOnChainIdTokenManagementFacetAbi);
    const tokenManagementCut = await prepareTokenManagementFacet(contractOwner,TokenManagementFacetAbi);
    const tokenOperationsCut = await prepareTokenOperationsFacet(contractOwner,TokenOperationsFacetAbi);

    // Combine all facet cuts into a single array
    const cut = [diamondLoupeFacetCut, ownershipFacetCut, agentManagementCut,];

    diamond = await deployDiamond(contractOwner, cut);

    const privateKey = process.env.PRIVATE_KEY;
    account = privateKeyToAccount(privateKey as Hex);

    testClient = createWalletClient({
    account,
    chain: arbitrumSepolia,
    transport: http(process.env.API_URL),
    }).extend(publicActions);
 });

  it("should deploy facets and Diamond contract successfully", async function () {
    expect(diamond).to.not.be.null;
    expect(diamond.address).to.not.be.undefined;
  });

  it("should add an address as an agent", async function () {
    async function checkBalance() {
      const balance = await testClient.getBalance({ address: account.address });
      console.log(`Account balance: ${balance} ETH`);
     }
     
     checkBalance();
    // Assuming the Diamond contract has been deployed and the Facet has been added
    const agentAddress = "0x801C06e7027D5e03E1cFD9f55c70edd5837C5767";
    const addAgentResult = await testClient.writeContract({
      address: diamond.address,
      abi: AgentManagementFacetAbi,
      functionName: "addAgent",
      args: [agentAddress],
      account
    });
    expect(addAgentResult).to.not.be.null;
  });

  it("should remove an address as an agent", async function () {
    const agentAddress = "0xe4476Ca098Fa209ea457c390BB24A8cfe90FCac4"; // Example agent address

    const removeAgentResult = await testClient.writeContract({
      address: diamond.address,
      abi: AgentManagementFacetAbi,
      functionName: "removeAgent",
      args: [agentAddress],
      account,
    });
    expect(removeAgentResult).to.not.be.null;
  });

   it("should add a new facet successfully", async function () {
 
    // Deploy the new facet
    const facet = await hre.viem.deployContract("TokenManagement", []);
    const newFacetAddress = facet.address;

    const diamondCutFacetAbi = JSON.parse(
      readFileSync(
        join(
          __dirname,
          "../artifacts/contracts/DiamondCutFacet.sol/DiamondCutFacet.json"
        ),
        "utf8"
      )
    ).abi;

    const diamondLoupeFacetAbi = JSON.parse(
      readFileSync(
        join(
          __dirname,
          "../artifacts/contracts/DiamondLoupeFacet.sol/DiamondLoupeFacet.json"
        ),
        "utf8"
      )
    ).abi;

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
    const result = await testClient.writeContract({
      address: diamond.address,
      abi: diamondCutFacetAbi,
      functionName: "diamondCut",
      args,
      account,
    });

    expect(result).to.not.be.null; 


  });


  it("should Replace a facet successfully", async function () {
  
    // Deploy the new facet
    const facet = await hre.viem.deployContract("TokenOperation", []);
    const newFacetAddress = facet.address;

    const diamondCutFacetAbi = JSON.parse(
      readFileSync(
        join(
          __dirname,
          "../artifacts/contracts/DiamondCutFacet.sol/DiamondCutFacet.json"
        ),
        "utf8"
      )
    ).abi;

    const selectors = getSelectors({ abi: diamondCutFacetAbi });

    const diamondInit = await hre.viem.deployContract("DiamondInit", []);

    const args = [
      [
        {
          facetAddress: newFacetAddress,
          action: FacetCutAction.Replace,
          functionSelectors: selectors,
        },
      ],
      diamondInit.address,
      "0x",
    ];
    const result = await testClient.writeContract({
      address: diamond.address,
      abi: diamondCutFacetAbi,
      functionName: "diamondCut",
      args,
      account,
    });

    expect(result).to.not.be.null; 

  });


   it("should remove a facet successfully", async function () {

    // Deploy the new facet
    const facet = await hre.viem.deployContract("AgentManagement", []);
    const newFacetAddress = facet.address;

    const diamondCutFacetAbi = JSON.parse(
      readFileSync(
        join(
          __dirname,
          "../artifacts/contracts/DiamondCutFacet.sol/DiamondCutFacet.json"
        ),
        "utf8"
      )
    ).abi;

    const selectors = getSelectors({ abi: diamondCutFacetAbi });

    const diamondInit = await hre.viem.deployContract("DiamondInit", []);

    const args = [
      [
        {
          facetAddress: newFacetAddress,
          action: FacetCutAction.Remove,
          functionSelectors: selectors,
        },
      ],
      diamondInit.address,
      "0x",
    ];
    const result = await testClient.writeContract({
      address: diamond.address,
      abi: diamondCutFacetAbi,
      functionName: "diamondCut",
      args,
      account,
    });

    expect(result).to.not.be.null; 

  });

   it("should add and remove multiple agents", async function () {
    // Example agent addresses
    const agentAddresses = [
      "0xe4476Ca098Fa209ea457c390BB24A8cfe90FCac4",
      "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
      "0xaE2E7B3E299f033a522115b649cE7DAF1b36e80F",
    ];

    // Add agents
    for (const agentAddress of agentAddresses) {
      const addAgentResult = await testClient.writeContract({
        address: diamond.address,
        abi: AgentManagementFacetAbi,
        functionName: "addAgent",
        args: [agentAddress],
        account,
      });
      expect(addAgentResult).to.not.be.null;
    }

    // Remove agents
    for (const agentAddress of agentAddresses) {
      const removeAgentResult = await testClient.writeContract({
        address: diamond.address,
        abi: AgentManagementFacetAbi,
        functionName: "removeAgent",
        args: [agentAddress],
        account,
      });
      expect(removeAgentResult).to.not.be.null;
    }
  });

  it("should transfer tokens", async function () {

    // recipient address and transfer amount
    const recipientAddress = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC";
    const transferAmount = 100n;

    // Transfer tokens
    const transferTokenResult =  await testClient.writeContract({
      address: diamond.address,
      abi: TokenOperationsFacetAbi,
      functionName: "transferERC3643Token",
      args: [recipientAddress, transferAmount],
      account,
    });

    expect(transferTokenResult).to.not.be.null;

  });
}); 
