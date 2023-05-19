// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RachelCards is ERC721A, Ownable {
    using Strings for uint256;

    bool public _isSaleActive = false;

    bool public _revealed = false;

    uint256 public constant MAX_SUPPLY = 1000;

    uint256 public mintPrice = 0.08 ether;

    string baseURI;

    string public notRevealedUri = "ipfs://QmRm44t29VPtuVY7gQiQmr8qUGSAQ7zdZMg2j8jyJXwrKw";

    string public baseExtension = "";

    mapping(uint256 => string) private _tokenURIs;

    constructor() ERC721A("Rachel", "RACHEL"){
    }

    function mint(uint256 tokenQuantity) public payable  returns(uint256[] memory){
        require(
            totalSupply() + tokenQuantity <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );

        require(_isSaleActive, "Sale must be active to mint NFT");

        require(
            tokenQuantity * mintPrice <= msg.value,
            "Not enough ether sent"
        );

        uint256 startIndex = _nextTokenId();
        uint256[] memory tokenIds = new uint256[](tokenQuantity);
        for (uint256 i = 0; i < tokenQuantity; i++) {
            tokenIds[i] = startIndex + i;
        }

        _safeMint(msg.sender,tokenQuantity);
        return tokenIds;
    }

    function teamMint(uint256 tokenQuantity) public onlyOwner returns(uint256[] memory){
        require(
            totalSupply() + tokenQuantity <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
        require(_isSaleActive, "Sale must be active to mint NFT");

        uint256 startIndex = _nextTokenId();
        uint256[] memory tokenIds = new uint256[](tokenQuantity);
        for (uint256 i = 0; i < tokenQuantity; i++) {
            tokenIds[i] = startIndex + i;
        }

        _safeMint(msg.sender,tokenQuantity);
        return tokenIds;
    }

    function batchTransfer(uint256[] memory tokenIds,address to) public {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            transferFrom(msg.sender,to,tokenIds[i]);
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (_revealed == false) {
            return notRevealedUri;
        }

        return string(abi.encodePacked(baseURI, tokenId.toString(), baseExtension));
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function flipSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function flipReveal() public onlyOwner {
        _revealed = !_revealed;
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function withdraw1() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function balanceOf() public view returns(uint){
        return balanceOf(msg.sender);
    }
}
