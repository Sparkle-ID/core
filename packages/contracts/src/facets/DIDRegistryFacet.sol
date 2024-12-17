// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Modifiers} from "../libraries/LibAppStorage.sol";
import {LibDIDRegistry} from "../libraries/LibDIDRegistry.sol";

contract DIDRegistryFacet is Modifiers {

    /**
     * @notice Creates a new Decentralized Identifier (DID).
     * @dev Called by an authorized entity to register a DID with associated metadata.
     * @param _did The unique identifier representing the DID.
     * @param _owner The address of the DID owner.
     * @param _role The role associated with the DID.
     * @param _metadataURI URI pointing to metadata about the DID.
     * @param _expiresAt Expiration timestamp of the DID.
     * @param _didType The type/category of the DID being created.
     */
    function createDID(
        string memory _did,
        address _owner,
        string memory _role,
        string memory _metadataURI,
        uint256 _expiresAt,
        string memory _didType
    ) external {
        LibDIDRegistry.createDID(_did, _owner, _role, _metadataURI, _expiresAt, _didType);
    }

    /**
     * @notice Retrieves the details of a specified DID.
     * @dev This function returns the DID details if the DID exists.
     * @param _did The unique DID string to retrieve.
     * @return The DID details as a struct.
     */
    function getDID(string memory _did) external view returns (string memory) {
        return LibDIDRegistry.getDID(_did);
    }

    /**
     * @notice Updates metadata associated with an existing DID.
     * @dev Only the DID owner or an authorized entity can call this function.
     * @param _did The DID to update.
     * @param _metadataURI New metadata URI for the DID.
     */
    function updateDID(
        string memory _did,
        string memory _metadataURI
    ) external {
        LibDIDRegistry.updateDID(_did, _metadataURI);
    }

    /**
     * @notice Revokes a previously registered DID.
     * @dev Intended for the DID owner or an authorized entity to revoke a DID.
     * @param _did The DID to revoke.
     */
    function revokeDID(
        string memory _did
    ) external {
        LibDIDRegistry.revokeDID(_did);
    }

    /**
     * @notice Delegates control of a DID to another address.
     * @dev The DID owner or an authorized entity can assign a delegate.
     * @param _did The DID for which control is being delegated.
     * @param _delegate The address receiving delegated control.
     */
    function delegateControl(
        string memory _did,
        address _delegate
    ) external {
        LibDIDRegistry.delegateControl(_did, _delegate);
    }

    /**
     * @notice Transfers ownership of a DID to a new address.
     * @dev Only the current owner can transfer ownership.
     * @param _did The DID whose ownership is being transferred.
     * @param _newOwner The new owner address.
     */
    function transferOwnership(
        string memory _did,
        address _newOwner
    ) external {
        LibDIDRegistry.transferOwnership(_did, _newOwner);
    }

    /**
     * @notice Links a sub-DID to a parent DID.
     * @dev Enables hierarchical DID relationships for permission management.
     * @param _did The parent DID.
     * @param _subDID The sub-DID to link.
     */
    function linkDID(
        string memory _did,
        string memory _subDID
    ) external {
        LibDIDRegistry.linkDID(_did, _subDID);
    }

    /**
     * @notice Checks if a given DID is valid.
     * @dev Returns true if the DID exists and is not expired.
     * @param _did The DID to check.
     * @return A boolean indicating the validity of the DID.
     */
    function isDIDValid(
        string memory _did
    ) external view returns (bool) {
        return LibDIDRegistry.isDIDValid(_did);
    }

    /**
     * @notice Retrieves all sub-DIDs linked to a parent DID.
     * @dev Provides an array of linked sub-DIDs.
     * @param _did The parent DID whose sub-DIDs are being queried.
     * @return An array of linked sub-DIDs.
     */
    function getLinkedDIDs(
        string memory _did
    ) external view returns (string[] memory) {
        return LibDIDRegistry.getLinkedDIDs(_did);
    }
} 
