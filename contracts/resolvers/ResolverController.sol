// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";

contract ResolverController is Ownable {
    mapping(address => bool) public controllers;

    constructor() public {
        transferOwnership(msg.sender);
    }

    /**
     *  add the controller contract address.
     * @param controller: contract address of the Main Resolver.
     */
    function addController(address controller) external virtual onlyOwner {
        controllers[controller] = true;
    }

    /**
     *  remove the controller contract address.
     * @param controller: contract address of the Main Resolver.
     */
    function removeController(address controller) external virtual onlyOwner {
        controllers[controller] = false;
    }
}
