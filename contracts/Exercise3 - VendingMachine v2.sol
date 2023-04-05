// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.14;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract vendingMachine is Ownable {

    event newSnackAdded(string _name, uint32 _price);
    event snackRestocked(uint32 _id, uint32 amount);
    event snackSold(string name, uint32 _amount);

    address payable private owner;

    struct Snacks {
        uint32 id;
        string name;
        uint32 quantity;
        uint8 price;
    }
    mapping (uint32 => Snacks) stock;
    uint32 totalSnacks;
    Snacks[] allSnacks;

    constructor() {
        owner = payable(msg.sender);
        totalSnacks = 0;
    }

    function getAllSnacks() external view returns(Snacks[] memory _allSnacks) {
        return allSnacks;
    }

    function addNewSnack(string memory _name, uint32 _quantity, uint8 _price) external onlyOwner {
        require(bytes(_name).length != 0, "Error: Null name");
        require(_price != 0, "Error: Wrong Id number");
        require(_quantity != 0, "Error: Null quantity");

        for(uint8 i = 0; i < totalSnacks; i++) {
            require(!compareStrings(_name, stock[i].name));   
        }

        Snacks memory newSnack = Snacks(totalSnacks, _name, _quantity, _price);
        stock[totalSnacks] = newSnack;
        allSnacks.push(newSnack);
        totalSnacks++;

        emit newSnackAdded(_name, _price);
    }

    function restock(uint32 _id, uint32 amount) external onlyOwner {
        stock[_id].quantity += amount;
        allSnacks[_id].quantity = stock[_id].quantity;

        emit snackRestocked(_id, amount);
    }

    function getMachineBalance() external view onlyOwner returns(uint) {
        return address(this).balance;
    }

    function withdraw() external onlyOwner {
        owner.transfer(address(this).balance);
    }

    function buySnack(uint32 _id, uint32 _amount) external payable {
        require(_amount > 0, "Incorrect amount");
        require(stock[_id].quantity >= _amount, "Insufficient quantity");
        require(msg.value >= _amount*stock[_id].price);

        stock[_id].quantity -= _amount;
        allSnacks[_id].quantity = stock[_id].quantity;

        emit snackSold(stock[_id].name, _amount);
    }

    function compareStrings(string memory a, string memory b) internal pure returns(bool) {
        return (keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)));
    } 
}