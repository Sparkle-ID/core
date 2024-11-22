// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {Diamond, DiamondArgs} from "../../src/Diamond.sol";
import {IDiamondCut} from "../../src/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "../../src/interfaces/IDiamondLoupe.sol";
import {IERC173} from "../../src/interfaces/IERC173.sol";
import {AccessControlFacet} from "../../src/facets/AccessControlFacet.sol";
import {DiamondCutFacet} from "../../src/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../src/facets/DiamondLoupeFacet.sol";
import {OwnershipFacet} from "../../src/facets/OwnershipFacet.sol";
import {DiamondInit} from "../../src/upgradeInit/DiamondInit.sol";
import {DiamondTestHelper} from "../helpers/DiamondTestHelper.sol";
// import {UUPSTestHelper} from "../helpers/UUPSTestHelper.sol";

/**
 * @notice Deploys diamond contract with all of the facets
 */
abstract contract DiamondTestSetup is DiamondTestHelper {
    // diamond related contracts
    Diamond diamond;
    DiamondInit diamondInit;

    // diamond facets (which point to the core diamond and should be used across the tests)
    AccessControlFacet accessControlFacet;
    DiamondCutFacet diamondCutFacet;
    DiamondLoupeFacet diamondLoupeFacet;
    OwnershipFacet ownershipFacet;

    // diamond facet implementation instances (should not be used in tests, use only on upgrades)
    AccessControlFacet accessControlFacetImplementation;
    DiamondCutFacet diamondCutFacetImplementation;
    DiamondLoupeFacet diamondLoupeFacetImplementation;
    OwnershipFacet ownershipFacetImplementation;

    // facet names with addresses
    string[] facetNames;
    address[] facetAddressList;

    // helper addresses
    address owner;
    address admin;
    address user1;
    address contract1;
    address contract2;

    // selectors for all of the facets
    bytes4[] selectorsOfAccessControlFacet;
    bytes4[] selectorsOfDiamondCutFacet;
    bytes4[] selectorsOfDiamondLoupeFacet;
    bytes4[] selectorsOfOwnershipFacet;

    /// @notice Deploys diamond and connects facets
    function setUp() public virtual {
        // setup helper addresses
        owner = generateAddress("Owner", false, 10 ether);
        admin = generateAddress("Admin", false, 10 ether);
        user1 = generateAddress("User1", false, 10 ether);
        contract1 = generateAddress("Contract1", true, 10 ether);
        contract2 = generateAddress("Contract2", true, 10 ether);

        // set all function selectors
        selectorsOfAccessControlFacet = getSelectorsFromAbi(
            "/out/AccessControlFacet.sol/AccessControlFacet.json"
        );
        selectorsOfDiamondCutFacet = getSelectorsFromAbi(
            "/out/DiamondCutFacet.sol/DiamondCutFacet.json"
        );
        selectorsOfDiamondLoupeFacet = getSelectorsFromAbi(
            "/out/DiamondLoupeFacet.sol/DiamondLoupeFacet.json"
        );
        selectorsOfOwnershipFacet = getSelectorsFromAbi(
            "/out/OwnershipFacet.sol/OwnershipFacet.json"
        );

        // deploy facet implementation instances
        accessControlFacetImplementation = new AccessControlFacet();
        diamondCutFacetImplementation = new DiamondCutFacet();
        diamondLoupeFacetImplementation = new DiamondLoupeFacet();
        ownershipFacetImplementation = new OwnershipFacet();

        // prepare diamond init args
        diamondInit = new DiamondInit();
        facetNames = [
            "AccessControlFacet",
            "DiamondCutFacet",
            "DiamondLoupeFacet",
            "OwnershipFacet"
        ];
        DiamondInit.Args memory initArgs = DiamondInit.Args({
            admin: admin
        });
        // diamond arguments
        DiamondArgs memory _args = DiamondArgs({
            owner: owner,
            init: address(diamondInit),
            initCalldata: abi.encodeWithSelector(
                DiamondInit.init.selector,
                initArgs
            )
        });

        FacetCut[] memory cuts = new FacetCut[](4);

        cuts[0] = (
            FacetCut({
                facetAddress: address(accessControlFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfAccessControlFacet
            })
        );
        cuts[1] = (
            FacetCut({
                facetAddress: address(diamondCutFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfDiamondCutFacet
            })
        );
        cuts[2] = (
            FacetCut({
                facetAddress: address(diamondLoupeFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfDiamondLoupeFacet
            })
        );
        cuts[3] = (
            FacetCut({
                facetAddress: address(ownershipFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfOwnershipFacet
            })
        );
        

        // deploy diamond
        vm.prank(owner);
        diamond = new Diamond(_args, cuts);

        // initialize diamond facets which point to the core diamond contract
        accessControlFacet = AccessControlFacet(address(diamond));
        diamondCutFacet = DiamondCutFacet(address(diamond));
        diamondLoupeFacet = DiamondLoupeFacet(address(diamond));
        ownershipFacet = OwnershipFacet(address(diamond));

        // get all addresses
        facetAddressList = diamondLoupeFacet.facetAddresses();

        vm.startPrank(admin);

        
        // grand diamond Credit token minting and burning rights
        

        // init UUPS core contracts
        // __setupUUPS(address(diamond));


        vm.stopPrank();
    }
}