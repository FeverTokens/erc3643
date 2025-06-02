import hre from "hardhat";
import { FacetCutAction, getSelectors } from "../libraries/diamond";

export async function prepareTokenOperationsFacet(
  contractOwner: string,
  TokenOperationsFacetAbi: any,
): Promise<any> {
  const facet = await hre.viem.deployContract("TokenOperation", []);

  const selectors = getSelectors({ abi: facet.abi });

  return {
    action: FacetCutAction.Add,
    facetAddress: facet.address,
    functionSelectors: selectors,
  };
  
  return facet.address;
}
