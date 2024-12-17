// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

library LibDIDRegistry {

    bytes32 constant REGISTRY_CONTROL_STORAGE_SLOT =
        bytes32(uint256(keccak256("sparkle.contracts.registry.storage")) - 1) &
            ~bytes32(uint256(0xff));

    // Events
    event DIDCreated(string indexed did, address indexed owner, string metadataURI, uint256 timestamp);
    event DIDUpdated(string indexed did, string metadataURI, uint256 timestamp);
    event DIDRevoked(string indexed did, uint256 timestamp);
    event DIDDelegated(string indexed did, address indexed delegate, uint256 timestamp);
    event DIDOwnershipTransferred(string indexed did, address indexed newOwner, uint256 timestamp);
    event DIDLinked(string indexed did, string indexed linkedDID, uint256 timestamp);

    struct DID {
        uint256 id;                // Unique identifier for the DID
        address owner;             // Owner of the DID
        string metadataURI;        // Off-chain metadata (e.g., HFS URI)
        uint256 createdAt;         // Timestamp of creation
        uint256 updatedAt;         // Timestamp of last update
        uint256 expiresAt;         // Expiration timestamp (optional, 0 if perpetual)
        bool revoked;              // Whether the DID is revoked
        string role;               // Role of the entity (e.g., "patient", "provider")
        string didType;          // Type of DID (e.g., "individual", "institution", "governance")
        address delegate;        // Optional delegate
    }

    struct DIDRegistryStorageData {
        mapping(string => DID) dids;            // Maps DID strings to DID details
        mapping(string => string[]) linkedDIDs; // Maps a DID to its linked DIDs
    }

    function didRegistryStorage()
        internal
        pure
        returns (DIDRegistryStorageData storage l)
    {
        bytes32 slot = REGISTRY_CONTROL_STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    /**
     * @notice Creates a new DID entry with specified details.
     * @dev This function initializes a new DID with metadata, role, and type.
     * @param _did The unique DID string.
     * @param _owner The address of the DID owner.
     * @param _role The role associated with the DID.
     * @param _metadataURI The metadata URI linked to the DID.
     * @param _expiresAt The expiration timestamp of the DID.
     * @param _didType The type of DID being created.
     */
    function createDID(
        string memory _did,
        address _owner,
        string memory _role,
        string memory _metadataURI,
        uint256 _expiresAt,
        string memory _didType
    ) internal {
        DIDRegistryStorageData storage ss = didRegistryStorage();

        require(bytes(_did).length > 0, "DID cannot be empty");
        require(bytes(_metadataURI).length > 0, "Metadata URI cannot be empty");
        require(bytes(_role).length > 0, "Role must be specified");
        require(ss.dids[_did].createdAt == 0, "DID already exists");
        require(_expiresAt == 0 || _expiresAt > block.timestamp, "Invalid expiration timestamp");

        ss.dids[_did] = DID({
            id: uint256(keccak256(abi.encodePacked(_did))),
            owner: _owner,
            metadataURI: _metadataURI,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            expiresAt: _expiresAt,
            revoked: false,
            role: _role,
            didType: _didType,
            delegate: address(0)
        });

        emit DIDCreated(_did, _owner, _metadataURI, block.timestamp);
    }

    /**
     * @notice Retrieves the details of a specified DID.
     * @dev This function returns the DID details if the DID exists.
     * @param _did The unique DID string to retrieve.
     * @return The DID details as a struct.
     */
    function getDID(string memory _did) internal view returns (string memory) {
        DIDRegistryStorageData storage ss = didRegistryStorage();
        return ss.dids[_did].metadataURI;
    }

    /**
     * @notice Updates the metadata URI of an existing DID.
     * @dev This function updates metadata only if the DID exists and is not revoked.
     * @param _did The unique DID string.
     * @param _metadataURI The new metadata URI.
     */
    function updateDID(string memory _did, string memory _metadataURI) internal {
        DIDRegistryStorageData storage ss = didRegistryStorage();

        require(ss.dids[_did].createdAt > 0, "DID does not exist");
        require(!ss.dids[_did].revoked, "DID is revoked");
        require(bytes(_metadataURI).length > 0, "Metadata URI cannot be empty");

        ss.dids[_did].metadataURI = _metadataURI;
        ss.dids[_did].updatedAt = block.timestamp;

        emit DIDUpdated(_did, _metadataURI, block.timestamp);
    }

    /**
     * @notice Revokes a previously created DID.
     * @dev This function marks a DID as revoked, making it inactive.
     * @param _did The unique DID string to be revoked.
     */
    function revokeDID(string memory _did) internal {
        DIDRegistryStorageData storage ss = didRegistryStorage();

        require(ss.dids[_did].createdAt > 0, "DID does not exist");
        require(!ss.dids[_did].revoked, "DID already revoked");

        ss.dids[_did].revoked = true;

        emit DIDRevoked(_did, block.timestamp);
    }

    /**
     * @notice Delegates control of a DID to another address.
     * @dev Only the DID owner can delegate control.
     * @param _did The DID for which control is being delegated.
     * @param _delegate The address receiving delegated control.
     */
    function delegateControl(string memory _did, address _delegate) internal {
        DIDRegistryStorageData storage ss = didRegistryStorage();

        require(ss.dids[_did].createdAt > 0, "DID does not exist");
        require(ss.dids[_did].owner == msg.sender, "Only the owner can delegate control");

        ss.dids[_did].delegate = _delegate;

        emit DIDDelegated(_did, _delegate, block.timestamp);
    }

    /**
     * @notice Transfers ownership of a DID to a new address.
     * @dev This function allows the current owner to transfer control to another address.
     * @param _did The unique DID string.
     * @param _newOwner The new owner's address.
     */
    function transferOwnership(string memory _did, address _newOwner) internal {
        DIDRegistryStorageData storage ss = didRegistryStorage();

        require(ss.dids[_did].createdAt > 0, "DID does not exist");
        require(ss.dids[_did].owner == msg.sender, "Only the owner can transfer ownership");

        ss.dids[_did].owner = _newOwner;

        emit DIDOwnershipTransferred(_did, _newOwner, block.timestamp);
    }

    /**
     * @notice Links one DID to another.
     * @dev Both DIDs must exist before establishing the link.
     * @param _did The primary DID to link from.
     * @param _linkedDID The secondary DID to link to the primary.
     */
    function linkDID(string memory _did, string memory _linkedDID) internal {
        DIDRegistryStorageData storage ss = didRegistryStorage();

        require(ss.dids[_did].createdAt > 0, "DID does not exist");
        require(ss.dids[_linkedDID].createdAt > 0, "Linked DID does not exist");

        ss.linkedDIDs[_did].push(_linkedDID);

        emit DIDLinked(_did, _linkedDID, block.timestamp);
    }

    /**
     * @notice Checks if a specified DID is currently valid.
     * @dev A valid DID must exist, not be revoked, and must not be expired.
     * @param _did The unique DID string to check.
     * @return True if the DID is valid, otherwise false.
     */
    function isDIDValid(string memory _did) internal view returns (bool) {
        DIDRegistryStorageData storage ss = didRegistryStorage();

        DID memory did = ss.dids[_did];
        if (did.createdAt == 0 || did.revoked) {
            return false;
        }
        if (did.expiresAt > 0 && did.expiresAt <= block.timestamp) {
            return false;
        }
        return true;
    }

    /**
     * @notice Retrieves all DIDs linked to a specified DID.
     * @dev Returns an array of linked DIDs if they exist.
     * @param _did The primary DID whose linked DIDs are requested.
     * @return An array of linked DIDs.
     */
    function getLinkedDIDs(string memory _did) internal view returns (string[] memory) {
        DIDRegistryStorageData storage ss = didRegistryStorage();
        return ss.linkedDIDs[_did];
    }
}