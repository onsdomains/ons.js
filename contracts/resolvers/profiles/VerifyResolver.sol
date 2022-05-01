// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "../../ONSRegister.sol";
import "./IVerifyResolver.sol";
import "../ResolverController.sol";

contract VerifyResolver is IVerifyResolver, ResolverController {
    mapping(uint256 => mapping(address => bool)) verifies;

    ONSRegister ons;
    ResolverController RC;

    constructor(ONSRegister _ons, ResolverController _rc) public {
        ons = _ons;
        RC = _rc;
    }

    modifier onlyController() {
        require(
            RC.controllers(msg.sender),
            "ONS NFT_Resolver: YOU_HAVE_NO_PROMOTIONS"
        );
        _;
    }

    /**
     * get ONS name owner
     * @param tokenId of the ONS name.
     */
    function getNameOwner(uint256 tokenId) internal view returns (address) {
        address owner = ons.ownerOf(tokenId);
        return owner;
    }

    /**
     * verify a ONS domain.
     * May only be called by the owner of that Name.
     * @param tokenId of the ONS name.
     * @param _status set verify status.
     */
    function verifyONS(
        uint256 tokenId,
        bool _status,
        address _nameOwner
    ) external virtual onlyController {
        verifies[tokenId][_nameOwner] = _status;
        emit VerifyStatusChanged(tokenId, _status, _nameOwner);
    }

    /**
     * Returns the status of the ONS name.
     * @param tokenId of the ONS name.
     */
    function checkVerify(uint256 tokenId)
        external
        view
        virtual
        override
        returns (bool)
    {
        return verifies[tokenId][getNameOwner(tokenId)];
    }
}
