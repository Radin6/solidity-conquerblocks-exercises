// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract HotelRoom is Ownable{

    event roomPaid(address _occupant, uint value);

    enum roomStatus {OCCUPIED, AVAILABLE}
    roomStatus public Status;
    uint price = 1 ether;

    constructor() {
        Status = roomStatus.AVAILABLE;
    }

    function payRoom() internal {
        require(msg.value >= price);
        payable(owner()).transfer(price);
    }

    function takeRoom() external payable {
        require(Status == roomStatus.AVAILABLE);

        (bool sent, bytes memory data) = payable(owner()).call {value: msg.value}("");
        require(sent);

        payRoom();
        Status = roomStatus.OCCUPIED;
        emit roomPaid(msg.sender, msg.value);
    }
}