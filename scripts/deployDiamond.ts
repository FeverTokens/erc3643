import hre from "hardhat";
import {readFileSync} from "fs";
import {join} from "path";
import {encodeFunctionData} from "viem";

export async function deployDiamond(
	contractOwner: string,
	cut: any[],
): Promise<any> {
	// Deploy DiamondCutFacet
	const diamondCutFacet = await hre.viem.deployContract("DiamondCutFacet", []);
	console.log("DiamondCutFacet deployed:", diamondCutFacet.address);

	// Deploy DiamondInit
	const diamondInit = await hre.viem.deployContract("DiamondInit", []);
	console.log("DiamondInit deployed:", diamondInit.address);

	// Deploy ERC3643Facet
	const erc3643Facet = await hre.viem.deployContract("ERC3643Facet", []);
	console.log("ERC3643Facet deployed:", erc3643Facet.address);

	// Check if cut array is not empty and the first element has a facetAddress
	if (cut.length === 0 || !cut[0].facetAddress) {
		console.error(
			"The cut array is empty or the first element does not have a facetAddress property.",
		);
		return
	}


	// Deploy Diamond
	const Diamond = await hre.viem.deployContract("Diamond", [
		contractOwner as any,
		diamondCutFacet.address,
		diamondInit.address,
		erc3643Facet.address
		// "0xe4476Ca098Fa209ea457c390BB24A8cfe90FCac4", 
	]);
	console.log("Diamond deployed:", Diamond.address);

	// Load ABIs
	const diamondCutAbi = JSON.parse(
		readFileSync(
			join(
				__dirname,
				"../artifacts/contracts/interfaces/IDiamondCut.sol/IDiamondCut.json",
			),
			"utf8",
		),
	).abi;

	const diamondInitAbi = diamondInit.abi;

	// Create a contract instance using the wallet client
	const walletClient = await hre.viem.getWalletClient(
		contractOwner as `0x${string}`,
	);

	// Encode the initialization function call
	const functionCall = encodeFunctionData({
		abi: diamondInitAbi,
		functionName: "init",
	});

	// Upgrade diamond with facets using writeContract
	for (const facetCut of cut) {
		if (
			!facetCut.facetAddress ||
			!facetCut.functionSelectors ||
			facetCut.functionSelectors.length === 0
		) {
			console.error("Invalid facet cut:", facetCut);
			continue;
		}

		const diamondCutRequest = {
			address: Diamond.address,
			abi: diamondCutAbi,
			functionName: "diamondCut",
			args: [
				[facetCut], // Array of facet cuts
				diamondInit.address, // Address of the initialization function
				functionCall, // Calldata for the initialization function
			],
			account: contractOwner,
		};

		try {
			const diamondCutTxHash = await walletClient.writeContract(
				diamondCutRequest as any,
			);
			console.log("Diamond cut tx: ", diamondCutTxHash);
		} catch (error) {
			console.error("Failed to add facet:", error);
		}
	}
	return Diamond;
}
