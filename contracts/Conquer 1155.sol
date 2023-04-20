// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts@4.8.1/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.8.1/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts@4.8.1/token/ERC1155/extensions/ERC1155Supply.sol";

contract Conquer1155 is Ownable, ERC1155Supply {

    uint maxSupply = 3;
    uint price = 0.05 ether;
    uint priceWL = 0.01 ether;

    constructor() ERC1155("https://token-cdn-domain/") {}

    mapping (address => bool) whitelistMembers;
    bool public isWhitelistOpen = true;
    
    function whiteListMint(uint _id, uint _amount, uint _price) public payable {
        require(whitelistMembers[msg.sender]);
        _price = priceWL;
        standarMint(_id, _amount, _price);
    }

    function standarMint(uint _id, uint _amount, uint _price) internal {
        require(msg.value >= _price*_amount, "Not enought ETH");
        require(totalSupply(_id) + _amount <= maxSupply, "It is more than Max Supply");
        _mint(msg.sender, _id, _amount, "");
    }

    function mint(uint _id, uint _amount, uint _price) public payable {
        require(!whitelistMembers[msg.sender], "You are in the Whitelist, mint as Whitelist");
        require(msg.value >= price*_amount, "Not enought ETH");
        _price = price;
        standarMint(_id, _amount, _price);
    }

    function mintBatch(uint[] memory ids, uint[] memory amounts) public payable {
        for (uint i = 0; i < ids.length; i++) {

            uint totalPrice;
            totalPrice += amounts[i]*price;

            require(totalSupply(ids[i]) + amounts[i] >= maxSupply);
            require(msg.value >= totalPrice);
        }
        _mintBatch(msg.sender, ids, amounts, "");
    }

    function addMembers(address[] memory members) public onlyOwner {
        require(isWhitelistOpen);
        for (uint i = 0; i < members.length; i++) {
            whitelistMembers[members[i]]= true;
        }
    }

    function changeWhitelistStatus(bool status) public onlyOwner {
        isWhitelistOpen = status;
    }

    function withdraw() public payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

}