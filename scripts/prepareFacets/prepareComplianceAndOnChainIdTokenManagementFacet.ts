import hre from "hardhat";
import { FacetCutAction, getSelectors } from "../libraries/diamond";

export async function prepareComplianceAndOnChainIdTokenManagementFacet(
  contractOwner: string,
  ComplianceAndOnChainIdTokenManagementFacetAbi: any,
): Promise<any> {
  const facet = await hre.viem.deployContract("ComplianceOnChainId", []);

  const selectors = getSelectors({ abi: facet.abi });

  return {
    action: FacetCutAction.Add,
    facetAddress: facet.address,
    functionSelectors: selectors,
  };

  return facet.address;
}
