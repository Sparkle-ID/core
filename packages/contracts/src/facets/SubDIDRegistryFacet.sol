// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Modifiers} from "../libraries/LibAppStorage.sol";
import {LibSubDIDRegistry} from "../libraries/LibSubDIDRegistry.sol";

contract SubDIDRegistryFacet is Modifiers {

    function createSubDID(
        string memory _parentDID,
        string memory _subDID,
        string memory _metadataURI
    ) external {
        LibSubDIDRegistry.createSubDID(_parentDID, _subDID, _metadataURI);
    }

    function updateSubDID(
        string memory _subDID,
        string memory _metadataURI
    ) external {
        LibSubDIDRegistry.updateSubDID(_subDID, _metadataURI);
    }

    function revokeSubDID(
        string memory _subDID
    ) external {
        LibSubDIDRegistry.revokeSubDID(_subDID);
    }

    function grantPermission(
        string memory _subDID,
        string memory _permission
    ) external {
        LibSubDIDRegistry.grantPermission(_subDID, _permission);
    }

    function revokePermission(
        string memory _subDID,
        string memory _permission
    ) external {
        LibSubDIDRegistry.revokePermission(_subDID, _permission);
    }

    function hasPermission(
        string memory _subDID,
        string memory _permission
    ) external view returns (bool) {
        return LibSubDIDRegistry.hasPermission(_subDID, _permission);
    }

}