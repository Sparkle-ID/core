// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;


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

}