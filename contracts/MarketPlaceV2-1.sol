//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFT is ERC721URIStorage {
    uint count;

    constructor() ERC721("ConquerNFT", "CNFT") {count = 0;}

    function mint(string memory _tokenURI) external returns(uint) {
        count++;
        _safeMint(msg.sender, count);
        _setTokenURI(count, _tokenURI);

        return count;
    }
}