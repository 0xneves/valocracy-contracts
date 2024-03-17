// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IValocracy {
    /**
     * @dev Emitted when a soulbound token is attemps to be transferred to
     * another account that is not the zero address.
     */
    error TokenSoulbound();

    /**
     * @dev Emitted when a valor is updated or introduced.
     */
    event Mint(address indexed account, uint256 indexed valorId);

    /**
     * @dev Emitted when a valor is updated or introduced.
     */
    event ValorUpdate(uint256 indexed valorId, uint256 rarity, string metadata);

    /**
     * @dev Emitted when the Governor contract address is updated.
     */
    event GovernorUpdate(address indexed governor);

    /**
     * @dev Emitted when the treasury contract address is updated.
     */
    event TreasuryUpdate(address indexed treasury);

    /**
     * @dev Return the Governor contract address.
     *
     * The Governor contract must be provided by calling {setGovernor}.
     * Otherwise {Governance-vote} will revert.
     */
    function governor() external view returns (address);

    /**
     * @dev Return the Treasury contract address.
     *
     * The Treasury contract must be provided by calling {setTreasury}.
     * Otherwise {Valocracy-mint} will revert.
     */
    function treasury() external view returns (address);

    /**
     * @dev Return the total supply of NFTs in this contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Mints a new NFT.
     *
     * The level will be set to the level of the sender plus the rarity of the
     * valor. If the account is on vacancy, the level will be set to the rarity
     * of the valor. The expiration will be set to the current timestamp plus
     * the vacancy period.
     *
     * Requirements:
     *
     * - `valorId` must exist.
     * - `expiration` must be in the future.
     *
     * Emits a {Mint} event.
     */
    function mint(address account, uint256 valorId) external;

    /**
     * @dev Burn the given token ID.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     * - `msg.sender` must be the owner of the token.
     *
     * Emits a {Transfer} event to the Zero Address.
     */
    function burn(uint256 tokenId) external;

    /**
     * @dev Create a new Valor for the protocol.
     *
     * Valor is a NFT that represents governance power. Their characteristics
     * are its rarity and metadata. The rarity will determine the level of
     * governance power and the metadata will be for off-chain display.
     *
     * Requirements:
     *
     * - `msg.sender` must be the owner of the contract.
     *
     * Emits a {NewValor} event.
     */
    function setValor(
        uint256 valorId,
        uint64 rarity,
        string memory metadata
    ) external;

    /**
     * @dev Set the Treasury contract address.
     *
     * Requirements:
     *
     * - `msg.sender` must be the owner of the contract.
     */
    function setTreasury(address treasury_) external;

    /**
     * @dev Set the Governor contract address.
     *
     * Requirements:
     *
     * - `msg.sender` must be the owner of the contract.
     */
    function setGovernor(address governor_) external;
}
