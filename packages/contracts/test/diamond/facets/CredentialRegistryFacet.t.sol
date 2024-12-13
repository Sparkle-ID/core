// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../DiamondTestSetup.sol";

contract CredentialRegistryFacetTest is DiamondTestSetup {

    address secondAccount = address(0x4);
    address thirdAccount = address(0x5);
    address fourthAccount = address(0x6);
    address fifthAccount = address(0x7);

    bytes32 constant _ONE = keccak256(abi.encodePacked(uint256(1)));

    function setUp() public virtual override {
        super.setUp();

        vm.startPrank(admin);


        vm.stopPrank();
    }
}

contract ZeroStateBonding is CredentialRegistryFacetTest {

    
}