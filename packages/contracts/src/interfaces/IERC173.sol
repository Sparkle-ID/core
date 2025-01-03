// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @notice ERC-173 Contract Ownership Standard
 * @dev ERC-165 identifier for this interface is 0x7f5828d0
 */
interface IERC173 {
    /// @notice Emits when ownership of a contract changes
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @notice Returns owner's address
     * @return owner_ Owner address
     */
    function owner() external view returns (address owner_);

    /**
     * @notice Sets contract's owner to a new address
     * @dev Set _newOwner to address(0) to renounce any ownership
     * @param _newOwner The address of the new owner of the contract
     */
    function transferOwnership(address _newOwner) external;
}