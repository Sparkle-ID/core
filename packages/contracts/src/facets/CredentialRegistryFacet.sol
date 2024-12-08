// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Modifiers} from "../libraries/LibAppStorage.sol";
import {LibCredentialRegistry} from "../libraries/LibCredentialRegistry.sol";

contract CredentialRegistryFacet is Modifiers {

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

    function revokeCredential(
        uint256 _credentialId,
        string memory _issuerDID,
        string memory _subDID
    ) external {
        LibCredentialRegistry.revokeCredential(_credentialId, _issuerDID, _subDID);
    }

    function getCredential(uint256 _credentialId) external view returns(LibCredentialRegistry.Credential memory) {
        return LibCredentialRegistry.credentialStorage().credentials[_credentialId];
    }

    function getCredentialsForHolder(string memory _holderDID) external view returns(uint256[] memory) {
        return LibCredentialRegistry.credentialStorage().holderToVCs[_holderDID];
    }
}