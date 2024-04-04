import {expect} from "chai";
import hre from "hardhat";
import {getContract} from "viem";
import {readFileSync} from "fs";
import {join} from "path";
import {deployDiamond} from "../scripts/deployDiamond";
import {getSelectors, FacetCutAction} from "../scripts/libraries/diamond";
import {loadFixture} from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import {prepareDiamondLoupeFacet} from "../scripts/prepareFacets/prepareDiamondLoupeFacet";
import {prepareOwnershipFacet} from "../scripts/prepareFacets/prepareOwnershipFacet";
import {prepareERC3643Facet} from "../scripts/prepareFacets/prepareERC3643Facet";
import {createWalletClient, http, mainnet} from "viem";

// Assuming the deploy function correctly initializes the facets
const deploy = async () => {
	const wallet = await hre.viem.getWalletClients();
	const contractOwner = wallet[0].account.address;

	const walletClient = createWalletClient({
		wallet[0].account,
		chain: mainnet,
		transport: http(),
	});

	const erc3643FacetAbi = JSON.parse(
		readFileSync(
			join(
				__dirname,
				"../artifacts/contracts/facets/erc3643Package/ERC3643Facet.sol/ERC3643Facet.json",
			),
			"utf8",
		),
	).abi;

	// Deploy each facet individually
	const diamondLoupeFacetCut = await prepareDiamondLoupeFacet(contractOwner);
	const ownershipFacetCut = await prepareOwnershipFacet(contractOwner);
	const erc3643FacetCut = await prepareERC3643Facet(
		contractOwner,
		erc3643FacetAbi,
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
				"../artifacts/contracts/facets/DiamondCutFacet.sol/DiamondCutFacet.json",
			),
			"utf8",
		),
	);
	const diamondLoupeFacetAbi = JSON.parse(
		readFileSync(
			join(
				__dirname,
				"../artifacts/contracts/facets/DiamondLoupeFacet.sol/DiamondLoupeFacet.json",
			),
			"utf8",
		),
	);
	const ownershipFacetAbi = JSON.parse(
		readFileSync(
			join(
				__dirname,
				"../artifacts/contracts/facets/OwnershipFacet.sol/OwnershipFacet.json",
			),
			"utf8",
		),
	);

	const erc3643Facet = await hre.viem.deployContract("ERC3643Facet", []);

	const diamondCutFacet = getContract({
		address: diamondInstance.address as `0x${string}`,
		abi: diamondCutFacetAbi.abi,
		client: {wallet: wallet[0]},
	});
	// const diamondCutFacet = await hre.viem.deployContract("DiamondCutFacet", []);
	// const diamondInit = await hre.viem.deployContract("DiamondInit", []);

	// const diamondCutFacet = getContract({
	//     address: diamondAddress as `0x${string}`,
	//     abi: diamondCutFacetAbi.abi,
	//     // client: publicClient,

	// });
	// const diamondLoupeFacet = getContract({
	// 	address: diamondAddress as `0x${string}`,
	// 	abi: diamondLoupeFacetAbi.abi,
	// });

	// const ownershipFacet = getContract({
	// 	address: diamondAddress as `0x${string}`,
	// 	abi: ownershipFacetAbi.abi,
	// });

	return {
		diamondInstance,
		erc3643Facet,
	};
};

describe("DiamondTest", function () {
	let diamondInstance: any;
	// let diamondCutFacet: any;
	// let diamondLoupeFacet: any;
	// let ownershipFacet: any;
	let erc3643Facet: any;

	beforeEach(async function () {
		// diamondCutFacet: diamondCutFacetValue,
		// diamondLoupeFacet: diamondLoupeFacetValue,
		// ownershipFacet: ownershipFacetValue,
		const {
			diamondInstance: diamondInstanceValue,
			erc3643Facet: erc3643FacetValue,
		} = await loadFixture(deploy);

		diamondInstance = diamondInstanceValue;
		erc3643Facet = erc3643FacetValue;
	});

	// it("should deploy the diamond contract successfully", async function () {
	// 	expect(diamondCutFacet).to.not.be.undefined;
	// 	expect(diamondCutFacet.address).to.not.be.empty;
	// });

	// it.only("should deploy the diamond contract successfully", async function () {
	// 	// Define the facet cuts for the diamond
	// 	const cut = [
	// 		{
	// 			facetAddress: "0x1234567890123456789012345678901234567890", // Example facet address
	// 			action: "Add",
	// 			functionSelectors: ["0x12345678"], // Example function selector
	// 		},
	// 		// Add more facet cuts as needed
	// 	];

	// 	// Deploy the diamond contract
	// 	const diamondAddress = await deployDiamond(contractOwner, []);

	// 	// Assert that the diamond contract was deployed successfully
	// 	expect(diamondAddress).to.be.a("string");
	// 	expect(diamondAddress).to.have.length.greaterThan(0);
	// });

	// it("should deploy a diamond with multiple facets successfully", async function () {
	// 	// Test setup for multiple facet cuts
	// 	const cut = [
	// 		{
	// 			facetAddress: "0x1234567890123456789012345678901234567890", // Example facet address
	// 			action: "Add",
	// 			functionSelectors: ["0x12345678"], // Example function selector
	// 		},
	// 		{
	// 			facetAddress: "0x2345678901234567890123456789012345678901", // Another example facet address
	// 			action: "Add",
	// 			functionSelectors: ["0x23456789"], // Another example function selector
	// 		},
	// 	];

	// 	// Deploy the diamond contract
	// 	const diamondAddress = await deployDiamond([]);

	// 	// Assert that the diamond contract was deployed successfully
	// 	expect(diamondAddress).to.be.a("string");
	// 	expect(diamondAddress).to.have.length.greaterThan(0);
	// });

	it.only("should add a new facet successfully", async function () {
		// Deploy the new facet
		const facet = await hre.viem.deployContract("ERC3643Facet", []);
		// console.log("facet: ", facet);
		const newFacetAddress = facet.address; // Use the actual address of the deployed facet

		const newFacetAbi = JSON.parse(
			readFileSync(
				join(
					__dirname,
					"../artifacts/contracts/facets/erc3643Package/ERC3643Facet.sol/ERC3643Facet.json",
				),
				"utf8",
			),
		).abi;

		const selectors = getSelectors({abi: newFacetAbi});
		// console.log("selectors: ", selectors);

		// Prepare the facet cut
		const facetCut = {
			facetAddress: newFacetAddress,
			action: FacetCutAction.Add,
			functionSelectors: selectors,
		};

		// console.log("diamondCutFacet: ", diamondInstance);

		const diamondCutFacetAbi = JSON.parse(
			readFileSync(
				join(
					__dirname,
					"../artifacts/contracts/facets/DiamondCutFacet.sol/DiamondCutFacet.json",
				),
				"utf8",
			),
		);

		// Add the new facet
		await diamondInstance.abi.write.diamondCut([facetCut], 0, "0x");

		console.log("---->", facetCut);
		// Verify the new facet was added
		// const facets = await diamondLoupeFacet.abi.read.facets();
		// const facetAddresses = facets.map((facet: any) => facet.facetAddress);
		// expect(facetAddresses).to.include(newFacetAddress);
	});

	it("should remove a facet successfully", async function () {
		// Assuming the diamondCutFacet object is correctly initialized
		// if (typeof diamondCutFacet.write.diamondCut !== 'function') {
		//     throw new Error('diamondCutFacet does not have a diamondCut method');
		// }

		const facetToRemoveAddress = "0x0dcd1bf9a1b36ce34237eeafef220932846bcd82"; // Replace with actual facet address to remove
		const newFacetAbi = JSON.parse(
			readFileSync(
				join(
					__dirname,
					"../artifacts/contracts/facets/erc3643Package/ERC3643Facet.sol/ERC3643Facet.json",
				),
				"utf8",
			),
		).abi;

		const selectors = getSelectors({abi: newFacetAbi}); // Assuming newFacetAbi is the ABI of the facet to remove

		// Prepare the facet cut for removal
		const facetCut = {
			facetAddress: facetToRemoveAddress,
			action: FacetCutAction.Remove,
			functionSelectors: selectors,
		};

		// Remove the facet
		// await diamondCutFacet.write.diamondCut([facetCut], 0, '0x');

		// Verify the facet was removed
		// This part depends on how you can check if a facet is removed. You might need to implement a method in your contract to check this.
	});

	it("should check if a facet exists", async function () {
		const {diamondLoupeFacet} = await loadFixture(deploy);

		const facetAddressToCheck = "0x5fbdb2315678afecb367f032d93f642f64180aa3"; // Replace with actual facet address to check

		// Check if the facet exists
		const facets = await diamondLoupeFacet.abi.read.facetAddresses();
		const facetExists = facets.some(
			(facet: any) => facet.facetAddress === facetAddressToCheck,
		);

		expect(facetExists).to.be.true;
	});

	it("should verify the functionality of the ERC3643Facet", async function () {
		// Assuming the erc3643Facet object is correctly initialized
		const erc3643Facet = await hre.viem.deployContract("ERC3643Facet", []);

		if (typeof erc3643Facet.write.addAgent !== "function") {
			throw new Error("erc3643Facet does not have the expected method");
		}

		// Example test logic
		// const result = await erc3643Facet.write.someFunction(args);
		// expect(result).to.equal(expectedResult);
	});
});
