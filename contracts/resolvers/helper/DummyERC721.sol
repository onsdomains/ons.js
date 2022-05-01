// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

contract DummyERC721 is ERC721Enumerable {
    string public baseURI;

    constructor(string memory _baseURI) ERC721('dummy', 'DM') {
        baseURI = _baseURI;
    }

    /**
     * mint a dummy NFT.
     * @param amount of NFTs to mint.
     */
    function mint(uint256 amount) public {
        for (uint256 i = 1; i <= amount; i++) {
            _safeMint(msg.sender, totalSupply() + i);
        }
    }

    /**
     * get TokenURI
     * @param tokenId: id of the NFT token
     */
    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        string memory currentBaseURI = baseURI;
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, toString(tokenId))) : '';
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return '0';
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
