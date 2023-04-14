//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable {

    uint _ticketId;
    uint ticketPrice = 1 ether;

    mapping (address => address) player_contract;
    mapping (uint => address) ticketId_owner;
    NFTs[] public nfts;

    constructor() {
        _ticketId = 0;
    }

    function buyTicket(uint quantityToBuy) public payable {
        require(msg.value >= ticketPrice*quantityToBuy);

        for (uint i=0; i < quantityToBuy; i++) {
            NFTs nft = new NFTs(msg.sender, _ticketId);
            nfts.push(nft);
            player_contract[msg.sender] = address(nft);
            ticketId_owner[_ticketId] = msg.sender;
            _ticketId++;
        }
        
    }

    function getTickets() public view returns(NFTs[] memory) {
        return nfts;
    }

    function generateWinner() public onlyOwner returns(address) {
        require(address(this).balance > 1 ether);

        uint random = uint(keccak256(abi.encodePacked(block.timestamp)))%_ticketId;
        address winner = ticketId_owner[random];
        payable(winner).transfer(address(this).balance - 1 ether);
        payable(owner()).transfer(address(this).balance);
        return winner;
    }

}

contract NFTs is ERC721 {
    address lotteryContract;
    address owner;
    uint ticketId;

    constructor (address _owner, uint _ticketId) ERC721("LotteryChance", "LOC") {
        owner = _owner;
        ticketId = _ticketId;
        lotteryContract = msg.sender;
    }

    function mintNFT(address _owner, uint _ticketId) private {
        require(lotteryContract == msg.sender);
        _safeMint(_owner, _ticketId);
    }
}