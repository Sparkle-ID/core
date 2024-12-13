// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IAccessControl} from "../interfaces/IAccessControl.sol";
import {AccessControlInternal} from "../access/AccessControlInternal.sol";
import {LibAccessControl} from "../libraries/LibAccessControl.sol";
import {Modifiers} from "../libraries/LibAppStorage.sol";

/**
 * @title AccessControlFacet
 * @notice Role-based access control implementation
 * @dev Provides an interface for managing roles and permissions.
 *      Derived from OpenZeppelin's AccessControl and SolidState Solidity libraries.
 *      This contract ensures secure and structured access to sensitive functions.
 */
contract AccessControlFacet is
    Modifiers,
    IAccessControl,
    AccessControlInternal
{
    /**
     * @notice Grants a role to a specified account
     * @dev Callable only by accounts with the admin role for the specified role.
     * @param role The role to grant.
     * @param account The account to which the role is granted.
     */
    /// @inheritdoc IAccessControl
    function grantRole(
        bytes32 role,
        address account
    ) external onlyRole(_getRoleAdmin(role)) {
        return _grantRole(role, account);
    }

    /**
     * @notice Sets the admin role for a specific role
     * @dev Callable only by accounts with the admin privileges.
     * @param role The role for which the admin role is being set.
     * @param adminRole The new admin role.
     */
    /// @inheritdoc IAccessControl
    function setRoleAdmin(bytes32 role, bytes32 adminRole) external onlyAdmin {
        _setRoleAdmin(role, adminRole);
    }

    /**
     * @notice Checks if an account has a specific role
     * @param role The role to check.
     * @param account The account to verify.
     * @return True if the account has the role, false otherwise.
     */
    /// @inheritdoc IAccessControl
    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool) {
        return _hasRole(role, account);
    }

    /**
     * @notice Retrieves the admin role for a specific role
     * @param role The role whose admin role is being queried.
     * @return The admin role for the specified role.
     */
    /// @inheritdoc IAccessControl
    function getRoleAdmin(bytes32 role) external view returns (bytes32) {
        return _getRoleAdmin(role);
    }

    /**
     * @notice Revokes a role from a specific account
     * @dev Callable only by accounts with the admin role for the specified role.
     * @param role The role to revoke.
     * @param account The account from which the role is revoked.
     */
    /// @inheritdoc IAccessControl
    function revokeRole(
        bytes32 role,
        address account
    ) external onlyRole(_getRoleAdmin(role)) {
        return _revokeRole(role, account);
    }

    /**
     * @notice Allows an account to renounce a role it possesses
     * @dev Useful for accounts that no longer wish to retain a specific role.
     * @param role The role to renounce.
     */
    /// @inheritdoc IAccessControl
    function renounceRole(bytes32 role) external {
        return _renounceRole(role);
    }

    /**
     * @notice Checks if the contract is currently paused
     * @return True if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return LibAccessControl.paused();
    }

    /**
     * @notice Pauses all contract functions that are guarded by the `whenNotPaused` modifier
     * @dev Callable only by accounts with admin privileges. Pausing adds a safety mechanism.
     */
    function pause() external whenNotPaused onlyAdmin {
        LibAccessControl.pause();
    }

    /**
     * @notice Unpauses the contract, enabling all functions guarded by the `whenPaused` modifier
     * @dev Callable only by accounts with admin privileges. Unpausing resumes normal operations.
     */
    function unpause() external whenPaused onlyAdmin {
        LibAccessControl.unpause();
    }
}
