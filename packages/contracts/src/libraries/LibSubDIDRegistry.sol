// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library LibSubDIDRegistry {
    bytes32 constant SUBDID_STORAGE_SLOT =
        bytes32(uint256(keccak256("sparkle.contracts.subdid.storage")) - 1) &
        ~bytes32(uint256(0xff));

    // Events
    event SubDIDCreated(
        string indexed parentDID,
        string indexed subDID,
        string metadataURI,
        uint256 timestamp
    );
    event SubDIDUpdated(
        string indexed subDID,
        string metadataURI,
        uint256 timestamp
    );
    event SubDIDRevoked(string indexed subDID, uint256 timestamp);
    event PermissionGranted(
        string indexed subDID,
        string permission,
        uint256 timestamp
    );
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

    // Create a sub-DID
    function createSubDID(
        string memory _parentDID,
        string memory _subDID,
        string memory _metadataURI
    ) internal {
        SubDIDStorageData storage ss = subDIDStorage();

        require(bytes(_subDID).length > 0, "Sub-DID cannot be empty");
        require(bytes(_metadataURI).length > 0, "Metadata URI cannot be empty");
        require(ss.subDIDs[_subDID].createdAt == 0, "Sub-DID already exists");

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

    // Update metadata for a sub-DID
    function updateSubDID(string memory _subDID, string memory _metadataURI) internal {
        SubDIDStorageData storage ss = subDIDStorage();

        require(ss.subDIDs[_subDID].createdAt > 0, "Sub-DID does not exist");
        require(!ss.subDIDs[_subDID].revoked, "Sub-DID is revoked");
        require(bytes(_metadataURI).length > 0, "Metadata URI cannot be empty");

        ss.subDIDs[_subDID].metadataURI = _metadataURI;
        ss.subDIDs[_subDID].updatedAt = block.timestamp;

        emit SubDIDUpdated(_subDID, _metadataURI, block.timestamp);
    }

    // Revoke a sub-DID
    function revokeSubDID(string memory _subDID) internal {
        SubDIDStorageData storage ss = subDIDStorage();

        require(ss.subDIDs[_subDID].createdAt > 0, "Sub-DID does not exist");
        require(!ss.subDIDs[_subDID].revoked, "Sub-DID already revoked");

        ss.subDIDs[_subDID].revoked = true;

        emit SubDIDRevoked(_subDID, block.timestamp);
    }

    // Grant a specific permission to a sub-DID
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


    // Revoke a specific permission from a sub-DID
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


    // Check if a sub-DID has a specific permission
    function hasPermission(
        string memory _subDID,
        string memory _permission
    ) internal view returns (bool) {
        SubDIDStorageData storage ss = subDIDStorage();
        return ss.permissions[_subDID][_permission];
    }


}
