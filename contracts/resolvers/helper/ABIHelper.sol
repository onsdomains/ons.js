// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract ABIHelper {
    function ownerOf(uint256 _id) public view virtual returns (address);
    function tokenURI(uint256) public view virtual returns (string memory);
    function balanceOf(address _address, uint256 _id)
        public
        view
        virtual
        returns (uint256);
}
