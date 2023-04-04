// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18 <0.9.0;

contract Bank {

    event transferEvent(address from, address to, uint amount);
    mapping (address => uint) balance;

    function deposit(uint _amount) external returns(uint) {
        balance[msg.sender] += _amount;
        return balance[msg.sender];
    }

    function getBalance() external view returns(uint) {
        return balance[msg.sender];
    }

    function intTransfer(address _from, address _to, uint _amount) private {
        balance[_from] -= _amount;
        balance[_to] += _amount;
        emit transferEvent(_from, _to, _amount);
    }

    function transfer(address _to, uint _amount) public {
        intTransfer(msg.sender, _to, _amount);
    }
}