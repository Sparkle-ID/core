// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Modifiers} from "../libraries/LibAppStorage.sol";
import {LibCredentialRegistry} from "../libraries/LibCredentialRegistry.sol";

contract CredentialRegistryFacet is Modifiers {

    /**
     * @notice Issues a new credential using issuer, holder, and metadata information.
     * @dev Calls the underlying `LibCredentialRegistry.issueCredential` function.
     * @param _issuerDID The DID of the issuing entity.
     * @param _subDID The sub-DID associated with the issuer.
     * @param _holderDID The DID of the credential holder.
     * @param _credentialType The type of credential being issued.
     * @param _metadataURI URI linking to the metadata of the credential.
     * @param _expiresAt The expiration timestamp of the credential.
     * @return The unique ID of the issued credential.
     */
    function issueCredential(
        string memory _issuerDID,
        string memory _subDID,
        string memory _holderDID,
        string memory _credentialType,
        string memory _metadataURI,
        uint256 _expiresAt
    ) external returns(uint256) {
        return LibCredentialRegistry.issueCredential(_issuerDID, _subDID, _holderDID, _credentialType, _metadataURI, _expiresAt);
    }

    /**
     * @notice Revokes a previously issued credential.
     * @dev This function is intended to be called by the issuer or an authorized entity.
     *      It removes the credential from active records, marking it as revoked.
     * @param _credentialId The unique identifier of the credential to be revoked.
     * @param _issuerDID The DID of the entity issuing the revocation.
     * @param _subDID The sub-DID associated with the credential issuer.
     */
    function revokeCredential(
        uint256 _credentialId,
        string memory _issuerDID,
        string memory _subDID
    ) external {
        LibCredentialRegistry.revokeCredential(_credentialId, _issuerDID, _subDID);
    }

    /**
     * @notice Retrieves details of a specific credential by its ID.
     * @dev This function allows viewing credential information without altering contract state.
     * @param _credentialId The unique identifier of the credential to retrieve.
     * @return A struct containing the credential's metadata and status.
     */
    function getCredential(uint256 _credentialId) external view returns(LibCredentialRegistry.Credential memory) {
        return LibCredentialRegistry.credentialStorage().credentials[_credentialId];
    }

    /**
     * @notice Retrieves all credentials associated with a specific holder DID.
     * @dev This function supports credential lookups for a particular holder.
     * @param _holderDID The DID of the holder whose credentials are being queried.
     * @return An array of credential IDs linked to the holder.
     */
    function getCredentialsForHolder(string memory _holderDID) external view returns(uint256[] memory) {
        return LibCredentialRegistry.credentialStorage().holderToVCs[_holderDID];
    }
}
