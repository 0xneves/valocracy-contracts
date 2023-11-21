// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IDNFT} from "./IDNFT.sol";
import {ITreasury} from "./interface/ITreasury.sol";
import {IValocracy} from "./interface/IValocracy.sol";

contract Valocracy is ERC721, Ownable, IDNFT, IValocracy {
    /**
     * @dev The Governance Contract.
     */
    address private _governor;

    /**
     * @dev The Treasury Contract.
     */
    address private _treasury;

    /**
     * @dev The total supply of the Valocracy Contract.
     */
    uint256 private _totalSupply;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol`.
     */
    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {}

    /**
     * @dev See {IValocracy-governor}.
     */
    function governor() public view returns (address) {
        return _governor;
    }

    /**
     * @dev See {IValocracy-treasury}.
     */
    function treasury() public view returns (address) {
        return _treasury;
    }

    /**
     * @dev See {IValocracy-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return metadataOf(valorIdOf(tokenId));
    }

    /**
     * @dev See {IValocracy-mint}.
     */
    function mint(address account, uint256 valorId) public onlyOwner {
        unchecked {
            // Overflow: not possible because values will never reach 2^256.
            _totalSupply++;
            _setUserStats(
                account,
                levelOf(account) + rarityOf(valorId),
                block.timestamp + vacancyPeriod()
            );
        }

        _mint(account, _totalSupply);
        _setValorId(_totalSupply, valorId);

        ITreasury(_treasury).deposit(account, rarityOf(valorId));

        emit Mint(account, valorId);
    }

    /**
     * @dev See {IValocracy-setValor}.
     */
    function setValor(
        uint256 valorId,
        uint64 rarity,
        string memory metadata
    ) public onlyOwner {
        _setValor(valorId, rarity, metadata);
        emit ValorUpdate(valorId, rarity, metadata);
    }

    /**
     * @dev See {IValocracy-setGovernor}.
     */
    function setGovernor(address governor_) public onlyOwner {
        _governor = governor_;
        emit GovernorUpdate(governor_);
    }

    /**
     * @dev See {IValocracy-setTreasury}.
     */
    function setTreasury(address treasury_) public onlyOwner {
        _treasury = treasury_;
        emit TreasuryUpdate(treasury_);
    }

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
    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }

    /**
     * @dev Overriding the {ERC721-_beforeTokenTransfer} to make the token
     * soulbounded, making it non-transferable to another accounts.
     *
     * The account can still burn the token by sending to the zero address.
     *
     * Requirements:
     *
     * - `to` must be the zero address.
     */
    function _beforeTokenTransfer(
        address,
        address to,
        uint256 tokenId,
        uint256
    ) internal virtual override {
        if (to != address(0) && _exists(tokenId)) revert TokenSoulbound();
    }
}
