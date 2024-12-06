// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import { LibDIDRegistry } from "./LibDIDRegistry.sol";
import { LibSubDIDRegistry } from "./LibSubDIDRegistry.sol";


library LibCredentialRegistry {
    bytes32 constant CREDENTIAL_STORAGE_SLOT =
        bytes32(uint256(keccak256("sparkle.contracts.credential.storage")) - 1) &
        ~bytes32(uint256(0xff));

    // Events
    event CredentialIssued(
        uint256 indexed credentialId,
        string indexed issuerDID,
        string indexed holderDID,
        string credentialType,
        string metadataURI,
        uint256 issuedAt,
        uint256 expiresAt
    );
    event CredentialRevoked(uint256 indexed credentialId, uint256 revokedAt);

    // Structs
    struct Credential {
        uint256 id;              // Unique credential ID
        string issuerDID;        // DID of the credential issuer
        string holderDID;        // DID of the credential holder
        string credentialType;   // Type of credential (e.g., "MedicalRecord")
        string metadataURI;      // Off-chain metadata (e.g., HFS URI)
        uint256 issuedAt;        // Timestamp when the credential was issued
        uint256 expiresAt;       // Expiration timestamp (0 if perpetual)
        bool revoked;            // Whether the credential is revoked
    }

    // Todo: Support for specific type of credentials

    struct CredentialStorageData {
        uint256 nextCredentialId;                    // Counter for generating unique credential IDs
        mapping(uint256 => Credential) credentials;  // Maps credential IDs to Credential details
        mapping(string => uint256[]) holderToVCs;    // Maps holder DIDs to credential IDs
    }

    function credentialStorage()
        internal
        pure
        returns (CredentialStorageData storage l)
    {
        bytes32 slot = CREDENTIAL_STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    // Issue a credential
    function issueCredential(
        string memory _issuerDID,
        string memory _subDID, // Sub-DID of the issuer
        string memory _holderDID,
        string memory _credentialType,
        string memory _metadataURI,
        uint256 _expiresAt
    ) internal returns (uint256) {
        CredentialStorageData storage cs = credentialStorage();

        // Validate issuer and holder DIDs
        require(LibDIDRegistry.isDIDValid(_issuerDID), "Invalid issuer DID");
        require(LibDIDRegistry.isDIDValid(_holderDID), "Invalid holder DID");

        // Check Sub-DID permissions
        require(
            LibSubDIDRegistry.hasPermission(_subDID, "issue"),
            "Sub-DID lacks permission to issue credentials"
        );

        require(bytes(_credentialType).length > 0, "Credential type cannot be empty");
        require(bytes(_metadataURI).length > 0, "Metadata URI cannot be empty");
        require(_expiresAt == 0 || _expiresAt > block.timestamp, "Invalid expiration timestamp");

        uint256 credentialId = cs.nextCredentialId++;
        cs.credentials[credentialId] = Credential({
            id: credentialId,
            issuerDID: _issuerDID,
            holderDID: _holderDID,
            credentialType: _credentialType,
            metadataURI: _metadataURI,
            issuedAt: block.timestamp,
            expiresAt: _expiresAt,
            revoked: false
        });

        cs.holderToVCs[_holderDID].push(credentialId);

        emit CredentialIssued(
            credentialId,
            _issuerDID,
            _holderDID,
            _credentialType,
            _metadataURI,
            block.timestamp,
            _expiresAt
        );

        return credentialId;
    }

    // Revoke a credential
    function revokeCredential(
        uint256 _credentialId,
        string memory _issuerDID,
        string memory _subDID // Sub-DID of the issuer
    ) internal {
        CredentialStorageData storage cs = credentialStorage();

        // Validate issuer DID
        require(LibDIDRegistry.isDIDValid(_issuerDID), "Invalid issuer DID");

        // Check Sub-DID permissions
        require(
            LibSubDIDRegistry.hasPermission(_subDID, "revoke"),
            "Sub-DID lacks permission to revoke credentials"
        );

        // Check if the credential exists and is not already revoked
        require(cs.credentials[_credentialId].id == _credentialId, "Credential does not exist");
        require(!cs.credentials[_credentialId].revoked, "Credential already revoked");

        // Revoke the credential
        cs.credentials[_credentialId].revoked = true;

        emit CredentialRevoked(_credentialId, block.timestamp);
    }

    // Get details of a credential
    function getCredential(uint256 _credentialId)
        internal
        view
        returns (Credential memory)
    {
        CredentialStorageData storage cs = credentialStorage();

        require(cs.credentials[_credentialId].id == _credentialId, "Credential does not exist");

        return cs.credentials[_credentialId];
    }

    // Check if a credential is valid
    function isCredentialValid(uint256 _credentialId) internal view returns (bool) {
        CredentialStorageData storage cs = credentialStorage();

        Credential memory credential = cs.credentials[_credentialId];
        if (credential.revoked) {
            return false;
        }
        if (credential.expiresAt > 0 && credential.expiresAt <= block.timestamp) {
            return false;
        }
        return true;
    }

    // Get all credentials for a holder (Need to manage growth of this array)
    function getCredentialsForHolder(string memory _holderDID)
        internal
        view
        returns (uint256[] memory)
    {
        CredentialStorageData storage cs = credentialStorage();

        return cs.holderToVCs[_holderDID];
    }

}