// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITreasury {
    /**
     * @dev Emitted when a non-authorized account attempts to call a function.
     */
    error NotAuthorized(address caller);

    /**
     * @dev Emitted when a new deposit of shares is made.
     */
    event Deposit(address indexed receiver, uint256 shares);

    /**
     * @dev Emitted when a withdrawal of shares is made.
     */
    event Withdraw(
        address indexed owner,
        address indexed receiver,
        uint256 assets,
        uint256 shares
    );

    /**
     * @dev Returns the address of the underlying token used for the Vault
     * for accounting, depositing, and withdrawing.
     */
    function asset() external view returns (address assetTokenAddress);

    /**
     * @dev Returns the total amount of the underlying asset that is “managed”
     * by Vault.
     */
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /**
     * @dev Returns the amount of the underlying asset that would be returned
     * from withdrawing the given amount of shares.
     */
    function previewWithdraw(
        uint256 shares
    ) external view returns (uint256 assets);

    /**
     * @dev Deposits the given amount of shares into the Vault.
     */
    function deposit(address receiver, uint256 shares) external;

    /**
     * @dev Withdraws the given amount of shares from the Vault.
     */
    function withdraw(address receiver, uint256 shares) external;
}
