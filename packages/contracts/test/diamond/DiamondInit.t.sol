// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {DiamondInit} from "../../src/upgradeInit/DiamondInit.sol";
import {LibAppStorage} from "../../src/libraries/LibAppStorage.sol";
import "forge-std/Test.sol";

contract MockDiamondInit is DiamondInit {
    function toCheckNonReentrant() external nonReentrant {
        require(store.reentrancyStatus == 2, "reentrancyStatus: _NOT_ENTERED");

        DiamondInitTest(msg.sender).ping();
    }
}

contract DiamondInitTest is Test {
    DiamondInit dInit;

    function setUp() public {
        dInit = new DiamondInit();
    }

    function test_Init() public {
        DiamondInit.Args memory initArgs = DiamondInit.Args({
            admin: address(0x123)
        });
        dInit.init(initArgs);

        uint256 reentrancyStatus = uint256(vm.load(address(dInit), 0));
        assertEq(reentrancyStatus, 1);
    }

    function test_NonReentrant() public {
        MockDiamondInit mockDInit = new MockDiamondInit();

        vm.expectRevert("ReentrancyGuard: reentrant call");
        mockDInit.toCheckNonReentrant();
    }

    function ping() external {
        MockDiamondInit(msg.sender).toCheckNonReentrant();
    }
}