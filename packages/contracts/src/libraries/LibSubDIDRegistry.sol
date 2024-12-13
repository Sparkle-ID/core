// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./LibDIDRegistry.sol";

library LibSubDIDRegistry {
    bytes32 constant SUBDID_STORAGE_SLOT =
        bytes32(uint256(keccak256("sparkle.contracts.subdid.storage")) - 1) &
        ~bytes32(uint256(0xff));

    // Events
    /**
     * @notice Emitted when a sub-DID is created.
     * @param parentDID The parent DID linked to the sub-DID.
     * @param subDID The created sub-DID.
     * @param metadataURI URI pointing to the metadata of the sub-DID.
     * @param timestamp The timestamp of creation.
     */
    event SubDIDCreated(
        string indexed parentDID,
        string indexed subDID,
        string metadataURI,
        uint256 timestamp
    );

    /**
     * @notice Emitted when a sub-DID is updated.
     * @param subDID The updated sub-DID.
     * @param metadataURI The new metadata URI.
     * @param timestamp The timestamp of the update.
     */
    event SubDIDUpdated(
        string indexed subDID,
        string metadataURI,
        uint256 timestamp
    );

    /**
     * @notice Emitted when a sub-DID is revoked.
     * @param subDID The revoked sub-DID.
     * @param timestamp The timestamp of the revocation.
     */
    event SubDIDRevoked(string indexed subDID, uint256 timestamp);

    /**
     * @notice Emitted when a permission is granted to a sub-DID.
     * @param subDID The sub-DID receiving the permission.
     * @param permission The granted permission.
     * @param timestamp The timestamp when the permission was granted.
     */
    event PermissionGranted(
        string indexed subDID,
        string permission,
        uint256 timestamp
    );

    /**
     * @notice Emitted when a permission is revoked from a sub-DID.
     * @param subDID The sub-DID losing the permission.
     * @param permission The revoked permission.
     * @param timestamp The timestamp when the permission was revoked.
     */
    event PermissionRevoked(
        string indexed subDID,
        string permission,
        uint256 timestamp
    );

    struct SubDID {
        string parentDID;         // Parent DID (e.g., patient or institution)
        string metadataURI;       // Off-chain metadata (e.g., HFS URI)
        uint256 createdAt;        // Timestamp of creation
        uint256 updatedAt;        // Timestamp of last update
        bool revoked;             // Whether the sub-DID is revoked
    }

    struct SubDIDStorageData {
        mapping(string => SubDID) subDIDs;         // Maps sub-DID strings to SubDID details
        mapping(string => mapping(string => bool)) permissions; // Permissions for each sub-DID
    }

    /**
     * @notice Retrieves the sub-DID storage structure.
     * @return l The storage structure containing sub-DIDs and permissions.
     */
    function subDIDStorage()
        internal
        pure
        returns (SubDIDStorageData storage l)
    {
        bytes32 slot = SUBDID_STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    /**
     * @notice Creates a new sub-DID under a specified parent DID.
     * @dev Ensures that the sub-DID and metadata URI are not empty and that the parent DID is valid.
     * @param _parentDID The parent DID linking to the new sub-DID.
     * @param _subDID The unique sub-DID string being created.
     * @param _metadataURI URI pointing to metadata about the sub-DID.
     */
    function createSubDID(
        string memory _parentDID,
        string memory _subDID,
        string memory _metadataURI
    ) internal {
        SubDIDStorageData storage ss = subDIDStorage();

        require(bytes(_subDID).length > 0, "Sub-DID cannot be empty");
        require(bytes(_metadataURI).length > 0, "Metadata URI cannot be empty");
        require(ss.subDIDs[_subDID].createdAt == 0, "Sub-DID already exists");

        require(LibDIDRegistry.isDIDValid(_parentDID), "Invalid parent DID");

        ss.subDIDs[_subDID] = SubDID({
            parentDID: _parentDID,
            metadataURI: _metadataURI,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            revoked: false
        });

        // Todo: Add sub-DID to parent's list of sub-DIDs
        // Todo: Consider NFT minting for sub-DID

        emit SubDIDCreated(_parentDID, _subDID, _metadataURI, block.timestamp);
    }

    /**
     * @notice Updates the metadata of an existing sub-DID.
     * @dev Ensures that the sub-DID exists, is not revoked, and the metadata URI is not empty.
     * @param _subDID The sub-DID whose metadata is being updated.
     * @param _metadataURI The new metadata URI.
     */
    function updateSubDID(string memory _subDID, string memory _metadataURI) internal {
        SubDIDStorageData storage ss = subDIDStorage();

        require(ss.subDIDs[_subDID].createdAt > 0, "Sub-DID does not exist");
        require(!ss.subDIDs[_subDID].revoked, "Sub-DID is revoked");
        require(bytes(_metadataURI).length > 0, "Metadata URI cannot be empty");

        ss.subDIDs[_subDID].metadataURI = _metadataURI;
        ss.subDIDs[_subDID].updatedAt = block.timestamp;

        emit SubDIDUpdated(_subDID, _metadataURI, block.timestamp);
    }

    /**
     * @notice Revokes a previously created sub-DID.
     * @dev Marks the sub-DID as revoked and emits a revocation event.
     * @param _subDID The sub-DID to be revoked.
     */
    function revokeSubDID(string memory _subDID) internal {
        SubDIDStorageData storage ss = subDIDStorage();

        require(ss.subDIDs[_subDID].createdAt > 0, "Sub-DID does not exist");
        require(!ss.subDIDs[_subDID].revoked, "Sub-DID already revoked");

        ss.subDIDs[_subDID].revoked = true;

        emit SubDIDRevoked(_subDID, block.timestamp);
    }

    /**
     * @notice Grants a specific permission to a sub-DID.
     * @dev Ensures that the sub-DID exists, is not revoked, and grants the specified permission.
     * @param _subDID The sub-DID receiving the permission.
     * @param _permission The granted permission.
     */
    function grantPermission(
        string memory _subDID,
        string memory _permission
    ) internal {
        SubDIDStorageData storage ss = subDIDStorage();

        require(ss.subDIDs[_subDID].createdAt > 0, "Sub-DID does not exist");
        require(!ss.subDIDs[_subDID].revoked, "Sub-DID is revoked");

        ss.permissions[_subDID][_permission] = true;

        emit PermissionGranted(_subDID, _permission, block.timestamp);
    }


    /**
     * @notice Revokes a specific permission from a sub-DID.
     * @dev Ensures that the sub-DID exists and that the specified permission is currently granted.
     * @param _subDID The sub-DID losing the permission.
     * @param _permission The permission being revoked.
     */
    function revokePermission(
        string memory _subDID,
        string memory _permission
    ) internal {
        SubDIDStorageData storage ss = subDIDStorage();

        require(ss.subDIDs[_subDID].createdAt > 0, "Sub-DID does not exist");
        require(ss.permissions[_subDID][_permission], "Permission not granted");

        ss.permissions[_subDID][_permission] = false;

        emit PermissionRevoked(_subDID, _permission, block.timestamp);
    }


    /**
     * @notice Checks if a sub-DID has a specific permission.
     * @dev Returns true if the permission is currently granted.
     * @param _subDID The sub-DID being checked.
     * @param _permission The permission being verified.
     * @return True if the permission is granted, otherwise false.
     */
    function hasPermission(
        string memory _subDID,
        string memory _permission
    ) internal view returns (bool) {
        SubDIDStorageData storage ss = subDIDStorage();
        return ss.permissions[_subDID][_permission];
    }


}
