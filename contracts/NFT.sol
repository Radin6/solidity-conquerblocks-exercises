// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721, Ownable {

    uint256 counter;
    uint256 price = 2 ether;
    uint256 priceLevelUp = 1 ether;

    struct Nft{
        string name;
        uint256 id;
        uint8 level;
        uint8 rarity;
    }

    Nft[] nfts;

    // Events

    event newNFT(address owner, uint256 _id, string name);

    constructor (string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        counter = 0;
    }

    // Functions

    function createRandomNFT(string memory _name) public payable {
        require(msg.value >= price, "Inssuficient money");
        _createNFT(_name);
        uint256 remainder = msg.value - price;
        payable(msg.sender).transfer(remainder);
    }

    function levelUp(uint256 _id) public payable {
        require(msg.value >= priceLevelUp, "Inssuficient money");
        require(ownerOf(_id) == msg.sender, "Wrong owner");
        nfts[_id].level++; 

        uint256 remainder = msg.value - priceLevelUp;
        payable(msg.sender).transfer(remainder);
    }

    function withdraw() external payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function updatePrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function updatePriceLevel (uint256 _priceLevelUp) external onlyOwner {
        priceLevelUp = _priceLevelUp;
    }

    function getAllNfts() external view returns(Nft[] memory) {
        return nfts;
    }

    function getContractBalance() external view returns(uint) {
        return address(this).balance;
    }

    // Internal Functions

    function _randomNumber(uint256 _range) internal view returns(uint256) {
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, block.timestamp));
        uint256 randomNumber = uint256(hash);

        return randomNumber % _range;
    }

    function _createNFT(string memory _name) internal  {
        uint8 _rarity = uint8(_randomNumber(1000));

        Nft memory newToken = Nft(_name, counter, 1, _rarity);
        _safeMint(msg.sender, counter);
        nfts.push(newToken);

        emit newNFT(msg.sender, counter, _name);
        counter++;
    }
}