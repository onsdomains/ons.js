// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface ITextResolver {
    event TextChanged(
        uint256 indexed tokenId,
        string indexed indexedKey,
        string key
    );

    /**
     * Returns the text data associated with an ONS TokenID and key.
     * @param tokenId of the ONS name.
     * @param key The text data key to query.
     * @return The associated text data.
     */
    function text(uint256 tokenId, string calldata key)
        external
        view
        returns (string memory);
}
