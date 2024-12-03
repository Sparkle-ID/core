// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;


library LibDIDRegistry {
    bytes32 constant CREDENTIAL_CONTROL_STORAGE_SLOT =
        bytes32(uint256(keccak256("sparkle.contracts.credential.storage")) - 1) &
            ~bytes32(uint256(0xff));

    struct Credential {
        string id;                  // Unique credential ID
        string issuer;              // Issuer DID
        string subject;             // Subject DID
        string context;             // Credential context
        string credentialType;      // Credential type
        string dataHash;            // Hash of credential data
        uint256 issuanceDate;       // Issuance timestamp
        uint256 expirationDate;     // Expiration timestamp
        bool revoked;               // Revocation status
    }

    struct CredentialStorageData {
        mapping(string => Credential) credentials;
    }

    function credentialRegistryStorage()
        internal
        pure
        returns (CredentialStorageData storage l)
    {
        bytes32 slot = CREDENTIAL_CONTROL_STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    event CredentialIssued(string indexed id, string issuer, string subject, uint256 issuanceDate);
    event CredentialRevoked(string indexed id, uint256 revokedAt);
}