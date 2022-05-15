// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TopLevelDomain is Ownable {
    event AddedDomain(string name, uint256 id);

    struct Domains {
        string domainName;
        uint256 domainID;
    }
    mapping(uint256 => Domains) public domains;

    uint256 domainCount;

    constructor(string memory domain) public {
        transferOwnership(msg.sender);

        domains[domainCount] = Domains(domain, domainCount);
        domainCount++;
    }

    /**
     * add a Top Domain to the List
     * @param _name: The name which should be added.
     */
    function addDomain(string memory _name) external onlyOwner {
        domains[domainCount] = Domains(_name, domainCount);
        domainCount++;
        emit AddedDomain(_name, domainCount);
    }

    /**
     * get the Top Domain using ID
     * @param _id: the ID of the Top Domain.
     */
    function getDomain(uint256 _id) public view returns (string memory) {
        return domains[_id].domainName;
    }
}
