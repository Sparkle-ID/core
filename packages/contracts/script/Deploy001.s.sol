// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {Script} from "forge-std/Script.sol";
import {Diamond, DiamondArgs} from "../../src/Diamond.sol";
import {AccessControlFacet} from "../../src/facets/AccessControlFacet.sol";
import {DiamondCutFacet} from "../../src/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../src/facets/DiamondLoupeFacet.sol";
import {OwnershipFacet} from "../../src/facets/OwnershipFacet.sol";
import {IDiamondCut} from "../../src/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "../../src/interfaces/IDiamondLoupe.sol";
import {IERC173} from "../../src/interfaces/IERC173.sol";
import {DEFAULT_ADMIN_ROLE, PAUSER_ROLE} from "../../src/libraries/Constants.sol";
import {LibAccessControl} from "../../src/libraries/LibAccessControl.sol";
import {AppStorage, LibAppStorage, Modifiers} from "../../src/libraries/LibAppStorage.sol";
import {LibDiamond} from "../../src/libraries/LibDiamond.sol";
import {DiamondTestHelper} from "../../test/helpers/DiamondTestHelper.sol";
import {CredentialRegistryFacet} from "../../src/facets/CredentialRegistryFacet.sol";
import {DIDRegistryFacet} from "../../src/facets/DIDRegistryFacet.sol";
import {SubDIDRegistryFacet} from "../../src/facets/SubDIDRegistryFacet.sol";


/**
 * @notice It is expected that this contract is customized if you want to deploy your diamond
 * with data from a deployment script. Use the init function to initialize state variables
 * of your diamond. Add parameters to the init function if you need to.
 *
 * @notice How it works:
 * 1. New `Diamond` contract is created
 * 2. Inside the diamond's constructor there is a `delegatecall()` to `DiamondInit` with the provided args
 * 3. `DiamondInit` updates diamond storage
 */
contract DiamondInit is Modifiers {
    /// @notice Struct used for diamond initialization
    struct Args {
        address admin;
    }

    /**
     * @notice Initializes a diamond with state variables
     * @dev You can add parameters to this function in order to pass in data to set your own state variables
     * @param _args Init args
     */
    function init(Args memory _args) external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        LibAccessControl.grantRole(DEFAULT_ADMIN_ROLE, _args.admin);
        LibAccessControl.grantRole(PAUSER_ROLE, _args.admin);

        AppStorage storage appStore = LibAppStorage.appStorage();
        appStore.paused = false;

        // reentrancy guard
        _initReentrancyGuard();
    }
}

contract Deploy001_Diamond is Script, DiamondTestHelper {
    // env variables
    uint256 adminPrivateKey;
    uint256 ownerPrivateKey;

    // owner and admin addresses derived from private keys store in `.env` file
    address adminAddress;
    address ownerAddress;

    // diamond related contracts
    Diamond diamond;
    DiamondInit diamondInit;

    // diamond facet implementation instances (should not be used directly)
    AccessControlFacet accessControlFacetImplementation;
    DiamondCutFacet diamondCutFacetImplementation;
    DiamondLoupeFacet diamondLoupeFacetImplementation;
    OwnershipFacet ownershipFacetImplementation;
    CredentialRegistryFacet credentialRegistryFacetImplementation;
    DIDRegistryFacet didRegistryFacetImplementation;
    SubDIDRegistryFacet subDIDRegistryFacetImplementation;

    // selectors for all of the facets
    bytes4[] selectorsOfAccessControlFacet;
    bytes4[] selectorsOfDiamondCutFacet;
    bytes4[] selectorsOfDiamondLoupeFacet;
    bytes4[] selectorsOfOwnershipFacet;
    bytes4[] selectorsOfCredentialRegistryFacet;
    bytes4[] selectorsOfDIDRegistryFacet;
    bytes4[] selectorsOfSubDIDRegistryFacet;


    function run() public virtual {
        // read env variables
        adminPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");
        ownerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");

        adminAddress = vm.addr(adminPrivateKey);
        ownerAddress = vm.addr(ownerPrivateKey);

        //===================
        // Deploy Diamond
        //===================

        // start sending owner transactions
        vm.startBroadcast(ownerPrivateKey);

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
        selectorsOfCredentialRegistryFacet = getSelectorsFromAbi(
            "/out/CredentialRegistryFacet.sol/CredentialRegistryFacet.json"
        );
        selectorsOfDIDRegistryFacet = getSelectorsFromAbi(
            "/out/DIDRegistryFacet.sol/DIDRegistryFacet.json"
        );
        selectorsOfSubDIDRegistryFacet = getSelectorsFromAbi(
            "/out/SubDIDRegistryFacet.sol/SubDIDRegistryFacet.json"
        );

        // deploy facet implementation instances
        accessControlFacetImplementation = new AccessControlFacet();
        diamondCutFacetImplementation = new DiamondCutFacet();
        diamondLoupeFacetImplementation = new DiamondLoupeFacet();
        ownershipFacetImplementation = new OwnershipFacet();
        credentialRegistryFacetImplementation = new CredentialRegistryFacet();
        didRegistryFacetImplementation = new DIDRegistryFacet();
        subDIDRegistryFacetImplementation = new SubDIDRegistryFacet();

        // prepare DiamondInit args
        diamondInit = new DiamondInit();
        DiamondInit.Args memory diamondInitArgs = DiamondInit.Args({
            admin: adminAddress
        });
        // prepare Diamond arguments
        DiamondArgs memory diamondArgs = DiamondArgs({
            owner: ownerAddress,
            init: address(diamondInit),
            initCalldata: abi.encodeWithSelector(
                DiamondInit.init.selector,
                diamondInitArgs
            )
        });

        // prepare facet cuts
        FacetCut[] memory cuts = new FacetCut[](7);
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
        cuts[4] = (
            FacetCut({
                facetAddress: address(credentialRegistryFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfCredentialRegistryFacet
            })
        );
        cuts[5] = (
            FacetCut({
                facetAddress: address(didRegistryFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfDIDRegistryFacet
            })
        );
        cuts[6] = (
            FacetCut({
                facetAddress: address(subDIDRegistryFacetImplementation),
                action: FacetCutAction.Add,
                functionSelectors: selectorsOfSubDIDRegistryFacet
            })
        );


        // deploy diamond
        diamond = new Diamond(diamondArgs, cuts);

        // stop sending owner transactions
        vm.stopBroadcast();


        //=======================
        // Diamond permissions
        //=======================

        // start sending admin transactions
        vm.startBroadcast(adminPrivateKey);

        AccessControlFacet accessControlFacet = AccessControlFacet(
            address(diamond)
        );

        // grant diamond dollar minting and burning rights
        accessControlFacet.grantRole(
            PAUSER_ROLE,
            address(diamond)
        );

        // stop sending admin transactions
        vm.stopBroadcast();

    }


}