// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "./ITextResolver.sol";
import "../ResolverController.sol";

contract TextResolver is ITextResolver, ResolverController {
    mapping(uint256 => mapping(string => string)) texts;

    ResolverController RC;

    constructor(ResolverController _rc) public {
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
     * Sets the text data using an ONS tokenId and key.
     * May only be called by the owner of that Name.
     * @param tokenId of the ONS name.
     * @param key The key to set.
     * @param value The text data value to set.
     */
    function setText(
        uint256 tokenId,
        string calldata key,
        string calldata value
    ) external virtual onlyController {
        texts[tokenId][key] = value;
        emit TextChanged(tokenId, key, key);
    }

    /**
     * Returns the text data using an ONS TokenID and key.
     * @param tokenId of the ONS name.
     * @param key The text data key to query.
     * @return The associated text data.
     */
    function text(uint256 tokenId, string calldata key)
        external
        view
        virtual
        override
        returns (string memory)
    {
        return texts[tokenId][key];
    }
}
