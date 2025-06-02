import hre from "hardhat";
import {prepareDiamondLoupeFacet} from "./prepareFacets/prepareDiamondLoupeFacet";
import {prepareOwnershipFacet} from "./prepareFacets/prepareOwnershipFacet";
import {deployDiamond} from "./deployDiamond";
import {readFileSync} from "fs";
import {join} from "path";
import { prepareAgentManagementFacet } from "./prepareFacets/prepareAgentManagementFacet";
import { prepareComplianceAndOnChainIdTokenManagementFacet } from "./prepareFacets/prepareComplianceAndOnChainIdTokenManagementFacet";
import { prepareTokenManagementFacet } from "./prepareFacets/prepareTokenManagementFacet";
import { prepareTokenOperationsFacet } from "./prepareFacets/prepareTokenOperationsFacet";

async function main(): Promise<void> {
	const accounts = await hre.viem.getWalletClients();
	const contractOwner = accounts[0].account.address;

	const AgentManagementFacetAbi = JSON.parse(readFileSync(join(__dirname,"../artifacts/contracts/Packages/AgentManagement/AgentManagement.sol/AgentManagement.json",),"utf8",),
	).abi;

	const ComplianceAndOnChainIdTokenManagementFacetAbi = JSON.parse(readFileSync(join(__dirname,"../artifacts/contracts/Packages/ComplianceAndOnChainIdTokenManagement/ComplianceOnChainId.sol/ComplianceOnChainId.json",),"utf8",),
	).abi;

	const TokenManagementFacetAbi = JSON.parse(readFileSync(join(__dirname,"../artifacts/contracts/Packages/TokenManagement/TokenManagement.sol/TokenManagement.json",),"utf8",),
	).abi;

	const TokenOperationsFacetAbi = JSON.parse(readFileSync(join(__dirname,	"../artifacts/contracts/Packages/TokensOperations/TokenOperation.sol/TokenOperation.json",),"utf8",),
	).abi;

	// Deploy each facet individually
	const diamondLoupeFacetCut = await prepareDiamondLoupeFacet(contractOwner);
	const ownershipFacetCut = await prepareOwnershipFacet(contractOwner);
    const agentManagementCut = await prepareAgentManagementFacet(contractOwner,AgentManagementFacetAbi);
    const complianceCut = await prepareComplianceAndOnChainIdTokenManagementFacet(contractOwner,ComplianceAndOnChainIdTokenManagementFacetAbi);
    const tokenManagementCut = await prepareTokenManagementFacet(contractOwner,TokenManagementFacetAbi);
    const tokenOperationsCut = await prepareTokenOperationsFacet(contractOwner,TokenOperationsFacetAbi);

	// Combine all facet cuts into a single array
	const cut = [diamondLoupeFacetCut, ownershipFacetCut, agentManagementCut, complianceCut, tokenManagementCut, tokenOperationsCut];

	// Check if the cut array is not empty and each element has a facetAddress property
	if (cut.length === 0 || !cut[0].facetAddress) {
		console.error(
			"The cut array is empty or the first element does not have a facetAddress property.",
		);
		return; // Return early if the condition is not met
	}

	// Deploy the Diamond contract with the combined facet cuts
	await deployDiamond(contractOwner, cut);
}

if (require.main === module) {
	main()
		.then(() => process.exit(0))
		.catch((error) => {
			console.error(error);
			process.exit(1);
		});
}
