// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IIDNFT} from "./interface/IIDNFT.sol";

abstract contract IDNFT is IIDNFT {
    // Mapping from token ID to valor ID
    mapping(uint256 => uint256) private _valorIds;

    // Mapping from valor ID to rarity
    mapping(uint256 => uint256) private _rarity;

    // Mapping from valor ID to metadata
    mapping(uint256 => string) private _metadata;

    // Mapping from owner address to user level, expiration
    mapping(address => uint256) private _userStats;

    /**
     * @dev See {IValocracy-vacancy}.
     */
    function vacancyPeriod() public pure virtual returns (uint256) {
        return 180 days;
    }

    /**
     * @dev See {IValocracy-valorIdOf}.
     */
    function valorIdOf(uint256 tokenId) public view virtual returns (uint256) {
        return _valorIds[tokenId];
    }

    /**
     * @dev See {IValocracy-rarityOf}.
     */
    function rarityOf(uint256 valorId) public view virtual returns (uint256) {
        return _rarity[valorId];
    }

    /**
     * @dev See {IValocracy-metadataOf}.
     */
    function metadataOf(
        uint256 valorId
    ) public view virtual returns (string memory) {
        return _metadata[valorId];
    }

    /**
     * @dev See {IValocracy-expiryOf}.
     */
    function expiryOf(address account) public view virtual returns (uint256) {
        (, uint128 expiration) = _parseData(_userStats[account]);
        return _validateExpiry(expiration);
    }

    /**
     * @dev See {IValocracy-levelOf}.
     */
    function levelOf(address account) public view virtual returns (uint256) {
        (uint128 level, uint128 expiration) = _parseData(_userStats[account]);
        return _mana(level, _validateExpiry(expiration));
    }

    /**
     * @dev Validate if the expire is in the future.
     */
    function _validateExpiry(
        uint128 expiration
    ) internal view virtual returns (uint256) {
        if (expiration > block.timestamp) return expiration;
        return 0;
    }

    /**
     * @dev Sets the new expiration and level for the current account.
     */
    function _setUserStats(
        address account,
        uint256 level,
        uint256 expiration
    ) internal virtual {
        _userStats[account] = _packData(level, expiration);
    }

    /**
     * @dev Packs the level and expiration into a single uint256.
     */
    function _packData(
        uint256 level,
        uint256 expiration
    ) internal pure returns (uint256) {
        return level | (expiration << 128);
    }

    /**
     * @dev Unpacks the level and expiration from a single uint256.
     */
    function _parseData(
        uint256 validationData
    ) internal pure returns (uint128, uint128) {
        return (uint128(validationData), uint128(validationData >> 128));
    }

    /**
     * @dev Sets the rarity and metadata of a valor.
     */
    function _setValor(
        uint256 valorId,
        uint256 rarityId,
        string memory metadata
    ) internal virtual {
        _rarity[valorId] = rarityId;
        _metadata[valorId] = metadata;
    }

    /**
     * @dev Link the valor ID to the token ID.
     */
    function _setValorId(uint256 tokenId, uint256 valorId) internal virtual {
        _valorIds[tokenId] = valorId;
    }

    /**
     * @dev Returns true if the account exists.
     */
    function _exists(address account) internal view virtual returns (bool) {
        return _userStats[account] > 0;
    }

    /**
     * @dev Calculate the mana of an account. Mana is the amount of governance
     * power (level) that is currently active at the moment.
     *
     * We can think of mana as a gauge that is constantly drained over time.
     * The more mana you have, the more governance power you have.
     *
     * Mana can be replenished by minting new NFTs to the account.
     *
     * The mana is calculated as the product of the level and the time elapsed
     * since the last time the account was updated, then divided by the vacancy
     * period. Which means that the mana will decay over time.
     */
    function _mana(
        uint256 level,
        uint256 expiration
    ) public view virtual returns (uint256) {
        uint256 timeElapsed = expiration > 0 ? expiration - block.timestamp : 0;
        return (level * timeElapsed) / vacancyPeriod();
    }
}
