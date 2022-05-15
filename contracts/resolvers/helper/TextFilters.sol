// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";

contract TextFilters is Ownable {
    mapping(string => bool) public textFilterList;

    constructor() public {
        transferOwnership(msg.sender);
    }

    /**
     *  filter a text
     * @param _text: add a text to filter list.
     */
    function permittingText(string memory _text) external virtual onlyOwner {
        textFilterList[_text] = true;
    }

    /**
     *  remove a text from filter list
     * @param _text: remove a text from the filterlist.
     */
    function unpermittingText(string memory _text) external virtual onlyOwner {
        textFilterList[_text] = false;
    }
}
