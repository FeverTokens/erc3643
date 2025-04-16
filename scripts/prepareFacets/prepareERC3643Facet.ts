import hre from "hardhat";
import {FacetCutAction, getSelectors} from "../libraries/diamond";

export async function prepareERC3643Facet(
	contractOwner: string,
	erc3643FacetAbi: any,
): Promise<any> {
	const facet = await hre.viem.deployContract("ERC3643Facet", []);

	const selectors = getSelectors({abi: facet.abi});

	return {
		action: FacetCutAction.Add,
		facetAddress: facet.address,
		functionSelectors: selectors,
	};

	return facet.address;
}
