import hre from "hardhat";
import {FacetCutAction, getSelectors} from "../libraries/diamond";
//import "../../contracts/diamond/DiamondLoupe.sol";

export async function prepareDiamondLoupeFacet(
	contractOwner: string,
): Promise<any> {
	const facet = await hre.viem.deployContract("DiamondLoupe", []);

	const selectors = getSelectors({abi: facet.abi});

	const cut = {
		action: FacetCutAction.Add,
		facetAddress: facet.address,
		functionSelectors: selectors,
	};
	return cut;
}
