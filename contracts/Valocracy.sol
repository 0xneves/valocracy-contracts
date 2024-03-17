// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Votes} from "./Votes.sol";
import {IDNFT} from "./IDNFT.sol";
import {ITreasury} from "./interfaces/ITreasury.sol";
import {IValocracy} from "./interfaces/IValocracy.sol";

contract Valocracy is ERC721, Ownable, IDNFT, Votes, IValocracy {
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
     * @dev Returns the current amount of votes that `account` has.
     */
    function getVotes(address account) public view override returns (uint256) {
        return levelOf(account);
    }

    /**
     * @dev See {IValocracy-mint}.
     */
    function mint(address account, uint256 valorId) public onlyOwner {
        uint256 rarity = rarityOf(valorId);

        // Overflow: not possible because values will never reach 2^256 while rarity is kept low
        unchecked {
            _totalSupply++;

            _setUserStats(
                account,
                levelOf(account) + rarity,
                block.timestamp + vacancyPeriod()
            );

            ITreasury(_treasury).deposit(account, rarity * 1e18);
        }

        _mint(account, _totalSupply);
        _setValorId(_totalSupply, valorId);
        _transferVotingUnits(address(0), account, levelOf(account));

        emit Mint(account, valorId);
    }

    /**
     * @dev See {IValocracy-burn}.
     */
    function burn(uint256 tokenId) public {
        _burn(tokenId);
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
     * @dev Overriding the {ERC721-_transfer} to make the token
     * soulbounded, making it non-transferable to another account.
     *
     * The account can still burn the token calling {ERC721-burn}
     */
    function _transfer(address, address, uint256) internal pure override {
        revert TokenSoulbound();
    }

    /**
     * @dev Returns the balance of `account`.
     *
     * WARNING: Overriding this function will likely result in incorrect vote tracking.
     */
    function _getVotingUnits(
        address account
    ) internal view override returns (uint256) {
        return levelOf(account);
    }
}
