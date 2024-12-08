// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Modifiers} from "../libraries/LibAppStorage.sol";
import {LibDIDRegistry} from "../libraries/LibDIDRegistry.sol";

contract DIDRegistryFacet is Modifiers {

    function createDID(
        string memory _did,
        address _owner,
        string memory _role,
        string memory _metadataURI,
        uint256 _expiresAt,
        string memory _didType
    ) external {
        LibDIDRegistry.createDID(_did, _owner, _role, _metadataURI, _expiresAt, _didType);
    }

    function updateDID(
        string memory _did,
        string memory _metadataURI
    ) external {
        LibDIDRegistry.updateDID(_did, _metadataURI);
    }

    function revokeDID(
        string memory _did
    ) external {
        LibDIDRegistry.revokeDID(_did);
    }

    function delegateControl(
        string memory _did,
        address _delegate
    ) external {
        LibDIDRegistry.delegateControl(_did, _delegate);
    }

    function transferOwnership(
        string memory _did,
        address _newOwner
    ) external {
        LibDIDRegistry.transferOwnership(_did, _newOwner);
    }

    function linkDID(
        string memory _did,
        string memory _subDID
    ) external {
        LibDIDRegistry.linkDID(_did, _subDID);
    }

    function isDIDValid(
        string memory _did
    ) external view returns (bool) {
        return LibDIDRegistry.isDIDValid(_did);
    }

    function getLinkedDIDs(
        string memory _did
    ) external view returns (string[] memory) {
        return LibDIDRegistry.getLinkedDIDs(_did);
    }

}