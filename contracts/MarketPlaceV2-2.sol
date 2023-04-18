//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Marketplace2 is ReentrancyGuard {

    address payable public immutable feeAddress;
    uint immutable feePercentage;

    uint public tokenCount;

    constructor(uint _feePercentage) {
        feeAddress = payable(msg.sender);
        feePercentage = _feePercentage;
        tokenCount = 0;
    }

    struct Token {
        uint tokenId;
        IERC721 nft;
        uint nftId;
        uint price;
        address payable seller;
        bool sold;
    }
    
    event Offered (uint tokenId, address indexed nft, uint nftId, uint price, address indexed seller);
    event Bought (uint tokenId, address indexed nft, uint nftId, address indexed seller, address indexed buyer);

    mapping (uint => Token) public tokens;

    function offerToken(IERC721 _nft, uint _nftId, uint _price) public {
        require(_price > 0, "Error: Price is 0");

        _nft.transferFrom(msg.sender, address(this), _nftId);
        tokens[tokenCount] = Token(tokenCount, _nft, _nftId, _price, payable(msg.sender), false);
        tokenCount++;

        emit Offered (tokenCount,address(_nft), _nftId, _price, msg.sender);

    }

    function getPrice(uint _tokenId) public view returns(uint) {
        return (tokens[_tokenId].price*(100+feePercentage)/100);
    }

    function purchaseToken(uint _tokenId) public payable nonReentrant {
        require(_tokenId >= 0 && _tokenId <= tokenCount, "Token does not exist");
        require(msg.value >= getPrice(_tokenId), "Insuffient ethers");

        Token storage saleToken = tokens[_tokenId]; 

        require(!saleToken.sold);

        saleToken.seller.transfer(saleToken.price);
        feeAddress.transfer(getPrice(_tokenId)-saleToken.price);
        saleToken.sold = true;
        saleToken.nft.transferFrom(address(this), msg.sender, _tokenId);

        emit Bought(saleToken.tokenId, address(saleToken.nft), saleToken.nftId, saleToken.seller, msg.sender);

    }
}
