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

    // Update
    function updateDID(string memory _did, string memory _metadataURI) internal {
        DIDRegistryStorageData storage ss = didRegistryStorage();

        require(ss.dids[_did].createdAt > 0, "DID does not exist");
        require(!ss.dids[_did].revoked, "DID is revoked");
        require(bytes(_metadataURI).length > 0, "Metadata URI cannot be empty");

        ss.dids[_did].metadataURI = _metadataURI;
        ss.dids[_did].updatedAt = block.timestamp;

        emit DIDUpdated(_did, _metadataURI, block.timestamp);
    }

    // Revoke
    function revokeDID(string memory _did) internal {
        DIDRegistryStorageData storage ss = didRegistryStorage();

        require(ss.dids[_did].createdAt > 0, "DID does not exist");
        require(!ss.dids[_did].revoked, "DID already revoked");

        ss.dids[_did].revoked = true;

        emit DIDRevoked(_did, block.timestamp);
    }

    // Delegate control of a DID
    function delegateControl(string memory _did, address _delegate) internal {
        DIDRegistryStorageData storage ss = didRegistryStorage();

        require(ss.dids[_did].createdAt > 0, "DID does not exist");
        require(ss.dids[_did].owner == msg.sender, "Only the owner can delegate control");

        ss.dids[_did].delegate = _delegate;

        emit DIDDelegated(_did, _delegate, block.timestamp);
    }

    // Transfer ownership of a DID
    function transferOwnership(string memory _did, address _newOwner) internal {
        DIDRegistryStorageData storage ss = didRegistryStorage();

        require(ss.dids[_did].createdAt > 0, "DID does not exist");
        require(ss.dids[_did].owner == msg.sender, "Only the owner can transfer ownership");

        ss.dids[_did].owner = _newOwner;

        emit DIDOwnershipTransferred(_did, _newOwner, block.timestamp);
    }

    // Link one DID to another
    function linkDID(string memory _did, string memory _linkedDID) internal {
        DIDRegistryStorageData storage ss = didRegistryStorage();

        require(ss.dids[_did].createdAt > 0, "DID does not exist");
        require(ss.dids[_linkedDID].createdAt > 0, "Linked DID does not exist");

        ss.linkedDIDs[_did].push(_linkedDID);

        emit DIDLinked(_did, _linkedDID, block.timestamp);
    }

    // Check if a DID is valid
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

    // Get linked DIDs
    function getLinkedDIDs(string memory _did) internal view returns (string[] memory) {
        DIDRegistryStorageData storage ss = didRegistryStorage();
        return ss.linkedDIDs[_did];
    }
}