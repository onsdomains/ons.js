// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";

contract AdminController is Ownable {
    mapping(address => bool) public adminControllers;

    constructor() public {
        transferOwnership(msg.sender);
    }

    /**
     *  add the controller contract address.
     * @param _controller: contract address of the Main Resolver.
     */
    function addController(address _controller) external virtual onlyOwner {
        adminControllers[_controller] = true;
    }

    /**
     *  remove the controller contract address.
     * @param _controller: contract address of the Main Resolver.
     */
    function removeController(address _controller) external virtual onlyOwner {
        adminControllers[_controller] = false;
    }
}
