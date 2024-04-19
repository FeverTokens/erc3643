import hre from "hardhat";
import { prepareDiamondLoupeFacet } from "../scripts/prepareFacets/prepareDiamondLoupeFacet";
import { prepareOwnershipFacet } from "../scripts/prepareFacets/prepareOwnershipFacet";
import { prepareERC3643Facet } from "../scripts/prepareFacets/prepareERC3643Facet";
import { deployDiamond } from "../scripts/deployDiamond";
import { expect } from "chai";
import { getSelectors, FacetCutAction } from "../scripts/libraries/diamond";
import { readFileSync } from "fs";
import { join } from "path";
import { Hex, createWalletClient, http, publicActions } from "viem";
import { arbitrumSepolia } from "viem/chains";
import { privateKeyToAccount } from "viem/accounts";
import { config } from "dotenv";
config();

describe("Deployment Scripts Test", function () {
  // Initial test setup
  let diamond: any;
  let contractOwner: string;
  let erc3643FacetAbi: any;

  before(async function () {
    // Setup
    const accounts = await hre.viem.getWalletClients();
    contractOwner = accounts[0].account.address;
    erc3643FacetAbi = JSON.parse(
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

    // Deploy the Diamond contract with the combined facet cuts
    diamond = await deployDiamond(contractOwner, cut);
  });

  it("should deploy facets and Diamond contract successfully", async function () {
    // Verify facets
    expect(diamond).to.not.be.null;
    expect(diamond.address).to.not.be.undefined;
  });

  // Additional tests
  it("should add an address as an agent", async function () {
    const privateKey = process.env.PRIVATE_KEY;

    const account = privateKeyToAccount(privateKey as Hex);

    const testClient = createWalletClient({
      account,
      chain: arbitrumSepolia,
      transport: http(process.env.API_URL),
    }).extend(publicActions);
    // Assuming the Diamond contract has been deployed and the ERC3643Facet has been added
    const agentAddress = "0xe4476Ca098Fa209ea457c390BB24A8cfe90FCac4";
    const addAgentResult = await testClient.writeContract({
      address: diamond.address,
      abi: erc3643FacetAbi,
      functionName: "addAgent",
      args: [agentAddress],
      // account: contractOwner,
    });
    expect(addAgentResult).to.not.be.null;
    // Additional verification can be added here
  });

  it("should remove an address as an agent", async function () {
    const privateKey = process.env.PRIVATE_KEY;

    const account = privateKeyToAccount(privateKey as Hex);

    const testClient = createWalletClient({
      account,
      chain: arbitrumSepolia,
      transport: http(process.env.API_URL),
    }).extend(publicActions);
    const agentAddress = "0xe4476Ca098Fa209ea457c390BB24A8cfe90FCac4"; // Example agent address
    const removeAgentResult = await testClient.writeContract({
      address: diamond.address,
      abi: erc3643FacetAbi,
      functionName: "removeAgent",
      args: [agentAddress],
      // account: contractOwner,
    });
    expect(removeAgentResult).to.not.be.null;
    // Additional verification can be added here
  });

  it("should add a new facet successfully", async function () {
    const privateKey = process.env.PRIVATE_KEY;

    const account = privateKeyToAccount(privateKey as Hex);

    const testClient = createWalletClient({
      account,
      chain: arbitrumSepolia,
      transport: http(process.env.API_URL),
    }).extend(publicActions);
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

    //  const wallet = await hre.viem.getWalletClients();
    //  const contractOwner = wallet[0].account.address;
    //  const accountAddress = contractOwner;
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
    await testClient.writeContract({
      address: diamond.address,
      abi: diamondCutFacetAbi,
      functionName: "diamondCut",
      args,
      //  account: accountAddress,
      account,
    });
  });

  it("should add and remove multiple agents", async function () {
    const privateKey = process.env.PRIVATE_KEY;
    const account = privateKeyToAccount(privateKey as Hex);
    const testClient = createWalletClient({
      account,
      chain: arbitrumSepolia,
      transport: http(process.env.API_URL),
    }).extend(publicActions);

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
        abi: erc3643FacetAbi,
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
        abi: erc3643FacetAbi,
        functionName: "removeAgent",
        args: [agentAddress],
        account,
      });
      expect(removeAgentResult).to.not.be.null;
    }
  });

  it("should transfer tokens", async function () {
    const privateKey = process.env.PRIVATE_KEY;
    const account = privateKeyToAccount(privateKey as Hex);
    const testClient = createWalletClient({
      account,
      chain: arbitrumSepolia,
      transport: http(process.env.API_URL),
    }).extend(publicActions);

    // Example recipient address and transfer amount
    const recipientAddress = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC";
    const transferAmount = 100n;

    // Transfer tokens
    const transferTokenResult =  await testClient.writeContract({
      address: diamond.address,
      abi: erc3643FacetAbi,
      functionName: "transferERC3643Token",
      args: [recipientAddress, transferAmount],
      account,
    });

    expect(transferTokenResult).to.not.be.null;

  });
});
