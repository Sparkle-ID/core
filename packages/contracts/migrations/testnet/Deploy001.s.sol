// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
// import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
// import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Script} from "forge-std/Script.sol";
import {Diamond, DiamondArgs} from "../../src/Diamond.sol";
import {AccessControlFacet} from "../../src/facets/AccessControlFacet.sol";
// import {DiamondCutFacet} from "../../src/dollar/facets/DiamondCutFacet.sol";
// import {DiamondLoupeFacet} from "../../src/facets/DiamondLoupeFacet.sol";
// import {OwnershipFacet} from "../../src/dollar/facets/OwnershipFacet.sol";
import {IDiamondCut} from "../../src/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "../../src/interfaces/IDiamondLoupe.sol";
import {IERC173} from "../../src/interfaces/IERC173.sol";
import {DEFAULT_ADMIN_ROLE, PAUSER_ROLE} from "../../src/libraries/Constants.sol";
import {LibAccessControl} from "../../src/libraries/LibAccessControl.sol";
import {AppStorage, LibAppStorage, Modifiers} from "../../src/libraries/LibAppStorage.sol";
import {LibDiamond} from "../../src/libraries/LibDiamond.sol";
// import {MockChainLinkFeed} from "../../src/dollar/mocks/MockChainLinkFeed.sol";
// import {MockCurveStableSwapNG} from "../../src/dollar/mocks/MockCurveStableSwapNG.sol";
// import {MockCurveTwocryptoOptimized} from "../../src/dollar/mocks/MockCurveTwocryptoOptimized.sol";
// import {MockERC20} from "../../src/dollar/mocks/MockERC20.sol";
// import {DiamondTestHelper} from "../../test/helpers/DiamondTestHelper.sol";


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

contract Deploy001_Diamond_Dollar_Governance is Script, DiamondTestHelper {
    // env variables
    uint256 adminPrivateKey;
    uint256 ownerPrivateKey;
    uint256 initialDollarMintAmountWei;


}