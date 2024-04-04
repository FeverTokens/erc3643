import hre from "hardhat";
import {FacetCutAction, getSelectors} from "../libraries/diamond";

export async function prepareDiamondLoupeFacet(
	contractOwner: string,
): Promise<any> {
	const facet = await hre.viem.deployContract("DiamondLoupeFacet", []);

	const selectors = getSelectors({abi: facet.abi});

	const cut = {
		action: FacetCutAction.Add,
		facetAddress: facet.address,
		functionSelectors: selectors,
	};
	return cut;
}
