import hre from "hardhat";
import { FacetCutAction, getSelectors } from "../libraries/diamond";

export async function prepareAgentManagementFacet(
  contractOwner: string,
  AgentManagementFacetAbi:any,
): Promise<any> {
  const facet = await hre.viem.deployContract("AgentManagement", []);

  const selectors = getSelectors({ abi: facet.abi });

  return {
    action: FacetCutAction.Add,
    facetAddress: facet.address,
    functionSelectors: selectors,
  };

  return facet.address;
}
