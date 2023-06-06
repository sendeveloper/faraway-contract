// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./ERC721Pausable.sol";

contract NFTCollection is ERC721Enumerable, Ownable, ERC721Burnable, ERC721Pausable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;

    uint256 private constant PRICE = 5 * 10 ** 16;
    uint256 private constant MAX_SUPPLY = 20;
    string private baseTokenURI;

    mapping(uint256 => bool) private _isOccupiedId;

    event TokenMinted(address collection, address recipient, uint256 tokenId, string tokenURI);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseTokenURI
    ) ERC721(_name, _symbol) {
        baseTokenURI = _baseTokenURI;
    }

    function mint(address payable _to) public payable {
        uint256 total = _totalSupply();

        require(total + 1 <= MAX_SUPPLY, "Current count exceeds maximum element count");
        require(msg.value >= PRICE, "Insufficient balance");

        _mintAnElement(_to);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function getTokenIdsOfWallet(address _owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);

        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }

    function _mintAnElement(address payable _to) private {
        uint256 tokenId = _generateTokenId();

        _tokenIdTracker.increment();
        _safeMint(_to, tokenId);
        _isOccupiedId[tokenId] = true;

        emit TokenMinted(address(this), _to, tokenId, tokenURI(tokenId));
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function _totalSupply() internal view returns (uint256) {
        return _tokenIdTracker.current();
    }

    function _createRandomNumber(uint256 seed) private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender,
                        seed
                    )
                )
            ) % MAX_SUPPLY + 1;
    }
    
    function _generateTokenId() private view returns (uint256) {
        uint256 tokenId;
        for(uint256 i = 0; ; i++) {
            tokenId = _createRandomNumber(i);
            if(!_isOccupiedId[tokenId]) 
                break;
        }
        return tokenId;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}