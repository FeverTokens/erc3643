import hre from "hardhat";
import {FacetCutAction, getSelectors} from "../libraries/diamond";

export async function prepareOwnershipFacet(
	contractOwner: string,
): Promise<any> {
	const facet = await hre.viem.deployContract("OwnershipFacet", []);
	const selectors = getSelectors({abi: facet.abi});
	const cut = {
		action: FacetCutAction.Add,
		facetAddress: facet.address,
		functionSelectors: selectors,
	};
	return cut;
}
