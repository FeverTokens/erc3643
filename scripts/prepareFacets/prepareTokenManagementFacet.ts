import hre from "hardhat";
import { FacetCutAction, getSelectors } from "../libraries/diamond";

export async function prepareTokenManagementFacet(
  contractOwner: string,
  TokenManagementFacetAbi: any,
): Promise<any> {
  const facet = await hre.viem.deployContract("TokenManagement", []);

  const selectors = getSelectors({ abi: facet.abi });

  return {
    action: FacetCutAction.Add,
    facetAddress: facet.address,
    functionSelectors: selectors,
  };

  return facet.address;
}
