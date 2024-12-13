// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Modifiers} from "../libraries/LibAppStorage.sol";
import {LibSubDIDRegistry} from "../libraries/LibSubDIDRegistry.sol";

contract SubDIDRegistryFacet is Modifiers {

    /**
     * @notice Creates a new sub-DID linked to a parent DID.
     * @dev This function is called to register a sub-DID under an existing parent DID.
     * @param _parentDID The parent DID to which the sub-DID is linked.
     * @param _subDID The unique identifier representing the sub-DID.
     * @param _metadataURI URI pointing to metadata related to the sub-DID.
     */
    function createSubDID(
        string memory _parentDID,
        string memory _subDID,
        string memory _metadataURI
    ) external {
        LibSubDIDRegistry.createSubDID(_parentDID, _subDID, _metadataURI);
    }

    /**
     * @notice Updates metadata associated with an existing sub-DID.
     * @dev Only authorized entities can update sub-DID metadata.
     * @param _subDID The sub-DID to update.
     * @param _metadataURI New metadata URI for the sub-DID.
     */
    function updateSubDID(
        string memory _subDID,
        string memory _metadataURI
    ) external {
        LibSubDIDRegistry.updateSubDID(_subDID, _metadataURI);
    }

    /**
     * @notice Revokes a previously registered sub-DID.
     * @dev This function is called by authorized entities to revoke a sub-DID.
     * @param _subDID The sub-DID to revoke.
     */
    function revokeSubDID(
        string memory _subDID
    ) external {
        LibSubDIDRegistry.revokeSubDID(_subDID);
    }

    /**
     * @notice Grants a specific permission to a sub-DID.
     * @dev Only authorized entities can assign permissions to sub-DIDs.
     * @param _subDID The sub-DID receiving the permission.
     * @param _permission The permission being granted.
     */
    function grantPermission(
        string memory _subDID,
        string memory _permission
    ) external {
        LibSubDIDRegistry.grantPermission(_subDID, _permission);
    }

    /**
     * @notice Revokes a specific permission from a sub-DID.
     * @dev This function removes an assigned permission from a sub-DID.
     * @param _subDID The sub-DID whose permission is being revoked.
     * @param _permission The permission being revoked.
     */
    function revokePermission(
        string memory _subDID,
        string memory _permission
    ) external {
        LibSubDIDRegistry.revokePermission(_subDID, _permission);
    }

    /**
     * @notice Checks if a sub-DID has a specific permission.
     * @dev Returns true if the specified permission is assigned to the sub-DID.
     * @param _subDID The sub-DID being checked.
     * @param _permission The permission to check.
     * @return A boolean indicating whether the permission exists.
     */
    function hasPermission(
        string memory _subDID,
        string memory _permission
    ) external view returns (bool) {
        return LibSubDIDRegistry.hasPermission(_subDID, _permission);
    }
} 
