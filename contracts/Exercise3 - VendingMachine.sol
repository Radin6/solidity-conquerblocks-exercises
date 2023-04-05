// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.14;

contract vendingMachine {

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

    Snacks[] stock;
    uint32 totalSnacks;

    constructor() {
        owner = payable(msg.sender);
        totalSnacks = 0;
    }

    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    function getAllSnacks() external view returns(Snacks[] memory _stock) {
        return stock;
    }

    function addNewSnack(string memory _name, uint32 _quantity, uint8 _price) external onlyOwner {
        require(bytes(_name).length != 0, "Error: Null name");
        require(_price != 0, "Error: Wrong Id number");
        require(_quantity != 0, "Error: Null quantity");

        for(uint8 i = 0; i < stock.length; i++) {
            require(!compareStrings(_name, stock[i].name));   
        }

        Snacks memory newSnack = Snacks(totalSnacks, _name, _quantity, _price);
        stock.push(newSnack);
        totalSnacks++;

        emit newSnackAdded(_name, _price);
    }

    function restock(uint32 _id, uint32 amount) external onlyOwner {
        stock[_id].quantity += amount;

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
        emit snackSold(stock[_id].name, _amount);
    }

    function compareStrings(string memory a, string memory b) internal pure returns(bool) {
        return (keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)));
    } 
}