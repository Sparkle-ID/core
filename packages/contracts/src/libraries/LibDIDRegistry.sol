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

    struct DID {
        uint256 id;                // Unique identifier for the DID
        string metadataURI;        // Off-chain metadata (e.g., HFS)
        uint256 createdAt;         // Timestamp of creation
        uint256 updatedAt;         // Timestamp of last update
        uint256 expiresAt;         // Expiration timestamp (optional, 0 if perpetual)
        bool revoked;              // Whether the DID is revoked
        string role;               // Role of the entity (e.g., "patient", "provider")
    }

    struct Attribute {
        string category;       // E.g., "Allergies", "Medications", "Lab Results"
        string key;            // Specific attribute key (e.g., "Peanuts", "Insulin")
        string value;          // Value of the attribute (e.g., "Severe", "10 units/day")
        uint256 createdAt;     // Timestamp of creation
        uint256 updatedAt;     // Timestamp of last update
        address author;        // Address of the entity who added/updated the attribute
    }


    struct DIDRegistryStorageData {
        mapping(address => DID) dids;
        mapping(string => Attribute[]) attributes;
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

    function createDID(address _owner, uint256 _id, string memory _did, string memory _role, string memory _metadataURI, uint256 _expiresAt) internal {
        DIDRegistryStorageData storage ss = didRegistryStorage();

        // require(ss.dids[_did].owner == address(0), "DID already exists");
        require(bytes(_metadataURI).length > 0, "Metadata URI cannot be empty");
        require(bytes(_role).length > 0, "Role must be specified");
        require(_expiresAt == 0 || _expiresAt > block.timestamp, "Expiration timestamp is invalid");


        ss.dids[_owner] = DID({
            id: _id,
            metadataURI: _metadataURI,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            expiresAt: _expiresAt,
            revoked: false,
            role: _role
        });

        emit DIDCreated(_did, msg.sender, _metadataURI, block.timestamp);
    }
}