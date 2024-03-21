import hre from "hardhat";
import { readFileSync } from 'fs';
import { join } from 'path';
import { encodeFunctionData } from 'viem';

export async function deployDiamond(cut: any[]): Promise<void> {
    const accounts = await hre.viem.getWalletClients();
    const contractOwner = accounts[0].account.address;

    // Deploy DiamondCutFacet
    const diamondCutFacet = await hre.viem.deployContract("DiamondCutFacet", []);
    console.log("DiamondCutFacet deployed:", diamondCutFacet.address);

    // Deploy DiamondInit
    const diamondInit = await hre.viem.deployContract("DiamondInit", []);
    console.log("DiamondInit deployed:", diamondInit.address);

    // Deploy Diamond
    const Diamond = await hre.viem.deployContract("Diamond", [
        contractOwner,
        diamondCutFacet.address,
        cut[2].facetAddress, // Assuming this is the ERC20Facet address
        "0xe4476Ca098Fa209ea457c390BB24A8cfe90FCac4", // Replaced placeholder with actual value
    ]);
    console.log("Diamond deployed:", Diamond.address);

    // Load ABIs
    const diamondCutAbi = JSON.parse(readFileSync(join(__dirname, '../artifacts/contracts/interfaces/IDiamondCut.sol/IDiamondCut.json'), 'utf8')).abi;    const diamondInitAbi = diamondInit.abi;

    // Create a contract instance using the wallet client
    const walletClient = await hre.viem.getWalletClient(contractOwner);

    // Encode the initialization function call
    const functionCall = encodeFunctionData({
        abi: diamondInitAbi,
        functionName: "init",
    });

    // Upgrade diamond with facets using writeContract
    for (const facetCut of cut) {
        if (!facetCut.facetAddress || !facetCut.functionSelectors || facetCut.functionSelectors.length === 0) {
            console.error("Invalid facet cut:", facetCut);
            continue;
        }

        const diamondCutRequest = {
            address: Diamond.address,
            abi: diamondCutAbi,
            functionName: 'diamondCut',
            args: [
                [facetCut], // Array of facet cuts
                diamondInit.address, // Address of the initialization function
                functionCall // Calldata for the initialization function
            ],
            account: contractOwner,
        };

        try {
            const diamondCutTxHash = await walletClient.writeContract(diamondCutRequest);
            console.log("Diamond cut tx: ", diamondCutTxHash);
        } catch (error) {
            console.error("Failed to add facet:", error);
        }
    }
}