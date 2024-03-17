// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IIDNFT {
    /**
     * @dev Returns the vacancy period. Vacancy is measured in seconds because
     * its the same unit of time as block.timestamp.
     *
     * The vacancy period is the time that an account has until its governance
     * power expires. It will be renewed after a new mint to the account.
     *
     * IMPORTANT: After loosing the governance power, what was lost cannot be
     * recovered. The account will have to mint new NFTs to start over. Hence,
     * the importance of not letting the governance power expire.
     *
     * WARNING: Changing the vacancy period affects the mana of all accounts.
     * Make sure to correctly calculate the desired vacancy period in SECONDS
     * and not in days, months or years. When making dynamic vacancy periods,
     * make sure to override the `_mana` function.
     */
    function vacancyPeriod() external view returns (uint256);

    /**
     * @dev Returns the valor ID linked to the given token ID.
     */
    function valorIdOf(uint256 tokenId) external view returns (uint256);

    /**
     * @dev Returns the rarity of the given valor ID.
     */
    function rarityOf(uint256 valorId) external view returns (uint256);

    /**
     * @dev Returns the metadata of the given valor ID.
     */
    function metadataOf(uint256 valorId) external view returns (string memory);

    /**
     * @dev Returns the level of governance power of a given account.
     */
    function levelOf(address account) external view returns (uint256);

    /**
     * @dev Expiration of the account. The governance power decays after the
     * vacancy period has passed. See {IValocracy-vacancyPeriod}.
     */
    function expiryOf(address account) external view returns (uint256);
}
