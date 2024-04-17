import hre from "hardhat";
import { prepareDiamondLoupeFacet } from './prepareFacets/prepareDiamondLoupeFacet';
import { prepareOwnershipFacet } from './prepareFacets/prepareOwnershipFacet';
import { prepareERC3643Facet } from './prepareFacets/prepareERC3643Facet';
import { deployDiamond } from './deployDiamond';
import { readFileSync } from 'fs';
import { join } from 'path';


async function main(): Promise<void> {
    const accounts = await hre.viem.getWalletClients();
    const contractOwner = accounts[0].account.address;
    const erc3643FacetAbi = JSON.parse(readFileSync(join(__dirname, '../artifacts/contracts/facets/erc3643Package/ERC3643Facet.sol/ERC3643Facet.json'), 'utf8')).abi;    

    // Deploy each facet individually
    const diamondLoupeFacetCut = await prepareDiamondLoupeFacet(contractOwner);
    const ownershipFacetCut = await prepareOwnershipFacet(contractOwner);
    const erc3643FacetCut = await prepareERC3643Facet(contractOwner, erc3643FacetAbi);

    // Combine all facet cuts into a single array
    const cut = [
        diamondLoupeFacetCut,
        ownershipFacetCut,
        erc3643FacetCut
    ];

    // Deploy the Diamond contract with the combined facet cuts
    await deployDiamond(contractOwner,cut);

  
}

if (require.main === module) {
    main()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
}