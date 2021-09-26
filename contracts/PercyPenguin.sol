// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC721PresetMinterPauserAutoId.sol";
import "./PercyPenguinGeneGenerator.sol";
import "./IPercyPenguin.sol";


contract PercyPenguin is IPercyPenguin, ERC721PresetMinterPauserAutoId, ReentrancyGuard {

    using PercyPenguinGeneGenerator for PercyPenguinGeneGenerator.Gene;
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    PercyPenguinGeneGenerator.Gene internal geneGenerator;

    address payable public daoAddress;
    uint256 public percyPenguinPrice;
    uint256 public maxSupply;
    uint256 public bulkBuyLimit;
    string public arweaveAssetsJSON;

    event TokenMorphed(uint256 indexed tokenId, uint256 oldGene, uint256 newGene, uint256 price, PercyPenguin.PercyPenguinEventType eventType);
    event TokenMinted(uint256 indexed tokenId, uint256 newGene);
    event PercyPenguinPriceChanged(uint256 newPercyPenguinPrice);
    event MaxSupplyChanged(uint256 newMaxSupply);
    event BulkBuyLimitChanged(uint256 newBulkBuyLimit);
    event BaseURIChanged(string baseURI);
    event arweaveAssetsJSONChanged(string arweaveAssetsJSON);

    enum PercyPenguinEventType { MINT, MORPH, TRANSFER }

    mapping (uint256 => uint256) internal _genes;

    constructor(string memory name, string memory symbol, string memory baseURI, address payable _daoAddress, uint premintedTokensCount, uint256 _percyPenguinPrice, uint256 _maxSupply, uint256 _bulkBuyLimit, string memory _arweaveAssetsJSON) ERC721PresetMinterPauserAutoId(name, symbol, baseURI) public {
        daoAddress = _daoAddress;
        percyPenguinPrice = _percyPenguinPrice;
        maxSupply = _maxSupply;
        bulkBuyLimit = _bulkBuyLimit;
        arweaveAssetsJSON = _arweaveAssetsJSON;
        geneGenerator.random();

        _preMint(premintedTokensCount);
    }

    function _preMint(uint256 amountToMint) internal {
        for (uint i = 0; i < amountToMint; i++) {
            _tokenIdTracker.increment();
            uint256 tokenId = _tokenIdTracker.current();
            _genes[tokenId] = geneGenerator.random();
            _mint(_msgSender(), tokenId);
        }
    }

    modifier onlyDAO() {
        require(msg.sender == daoAddress, "Not called from the DAO");
        _;
    }

    function geneOf(uint256 tokenId) public view virtual override returns (uint256 gene) {
        return _genes[tokenId];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721PresetMinterPauserAutoId) {
        ERC721PresetMinterPauserAutoId._beforeTokenTransfer(from, to, tokenId);
        emit TokenMorphed(tokenId, _genes[tokenId], _genes[tokenId], 0, PercyPenguinEventType.TRANSFER);
    }

    function mint() public override payable nonReentrant {
        require(_tokenIdTracker.current() < maxSupply, "Total supply reached");

        _tokenIdTracker.increment();

        uint256 tokenId = _tokenIdTracker.current();
        _genes[tokenId] = geneGenerator.random();

        (bool transferToDaoStatus, ) = daoAddress.call{value:percyPenguinPrice}("");
        require(transferToDaoStatus, "Address: unable to send value recipient may have reverted");

        uint256 excessAmount = msg.value.sub(percyPenguinPrice);
        if (excessAmount > 0) {
            (bool returnExcessStatus, ) = _msgSender().call{value: excessAmount}("");
            require(returnExcessStatus, "Failed to return excess.");
        }

        _mint(_msgSender(), tokenId);

        emit TokenMinted(tokenId, _genes[tokenId]);
        emit TokenMorphed(tokenId, 0, _genes[tokenId], percyPenguinPrice, PercyPenguinEventType.MINT);
    }

    function bulkBuy(uint256 amount) public override payable nonReentrant {
        require(amount <= bulkBuyLimit, "Cannot bulk buy more than the present limit");
        require(_tokenIdTracker.current().add(amount) <= maxSupply, "Total supply reached");

        (bool transferToDaoStatus, ) = daoAddress.call{value:percyPenguinPrice.mul(amount)}("");
        require(transferToDaoStatus, "Address: unable to send value, recipient may have reverted");

        uint256 excessAmount = msg.value.sub(percyPenguinPrice.mul(amount));
        if (excessAmount > 0) {
            (bool returnExcessStatus, ) = _msgSender().call{value: excessAmount}("");
            require(returnExcessStatus, "Failed to return excess.");
        }

        for (uint256 i = 0; i < amount; i++) {
            _tokenIdTracker.increment();

            uint256 tokenId = _tokenIdTracker.current();
            _genes[tokenId] = geneGenerator.random();
            _mint (_msgSender(), tokenId);

            emit TokenMinted(tokenId, _genes[tokenId]);
            emit TokenMorphed(tokenId, 0, _genes[tokenId], percyPenguinPrice, PercyPenguinEventType.MINT);
        }

    }

    function lastTokenId() public override view returns(uint256 tokenId) {
        return _tokenIdTracker.current();
    }

    function mint(address to) public override(ERC721PresetMinterPauserAutoId) {
        revert("should not use this one");
    }

    function setPercyPenguinsPrice(uint256 newPercyPenguinPrice) public override virtual onlyDAO {
        percyPenguinPrice = newPercyPenguinPrice;

        emit PercyPenguinPriceChanged(newPercyPenguinPrice);
    }

    function setMaxSupply(uint256 _maxSupply) public override virtual onlyDAO {
        maxSupply = _maxSupply;

        emit MaxSupplyChanged(maxSupply);
    }

    function setBulkBuyLimit(uint256 _bulkBuyLimit) public override virtual onlyDAO {
        bulkBuyLimit = _bulkBuyLimit;

        emit BulkBuyLimitChanged(_bulkBuyLimit);
    }

    function setBaseURI(string memory _baseURI) public virtual onlyDAO {
        _setBaseURI(_baseURI);

        emit BaseURIChanged(_baseURI);
    }

    function setArweaveAssetsJSON(string memory _arweaveAssetsJSON) public virtual onlyDAO {
        arweaveAssetsJSON = _arweaveAssetsJSON;

        emit arweaveAssetsJSONChanged(_arweaveAssetsJSON);
    }

    receive() external payable {
        mint();
    }

}
