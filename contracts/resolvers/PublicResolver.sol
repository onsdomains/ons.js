// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "../ONSRegister.sol";
import "./profiles/TextResolver.sol";
import "./profiles/NFTResolver.sol";
import "./profiles/VerifyResolver.sol";
import "./helper/TextFilters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PublicResolver is Ownable {
    ONSRegister ons;
    TextResolver textResolver;
    NFTResolver nftResolver;
    VerifyResolver verifyResolver;
    TextFilters textFilters;

    constructor(
        ONSRegister _ons,
        TextResolver _textResolver,
        NFTResolver _nftResolver,
        VerifyResolver _verifyResolver,
        TextFilters _textFilters
    ) {
        transferOwnership(msg.sender);
        ons = _ons;
        textResolver = _textResolver;
        nftResolver = _nftResolver;
        verifyResolver = _verifyResolver;
        textFilters = _textFilters;
    }

    /**
     * checking if the key is on the filter list
     * @param _key: the called key.
     */
    function filterText(string memory _key) internal view returns (bool) {
        return textFilters.textFilterList(_key);
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
     * checking if the caller is owner of the Name
     * @param tokenId of the ONS name.
     */
    function isAuthorised(uint256 tokenId) internal view returns (bool) {
        return getNameOwner(tokenId) == msg.sender;
    }

    /**
     * edit the text data using the ONS tokenId and key.
     * May only be called by the owner of that Name.
     * @param tokenId of the ONS name.
     * @param key The key to set.
     * @param value The text data value to set.
     */
    function editText(
        uint256 tokenId,
        string calldata key,
        string calldata value
    ) external {
        require(
            isAuthorised(tokenId),
            "ONS_RC: YOU_ARE_NOT_THE_OWNER_OF_THIS_NAME"
        );
        require(filterText(key), "ONS_RC: I_DONT_KNOW_THIS_KEY");
        textResolver.setText(tokenId, key, value);
    }

    /**
     * edit the NFT avatar using the ONS tokenId.
     * May only be called by the owner of that Name.
     * @param tokenId of the ONS name.
     * @param contractAddress The NFT contract address to set.
     * @param NFTId The token ID of the owned NFT by the caller.
     */
    function editNFT(
        uint256 tokenId,
        ABIHelper contractAddress,
        uint256 NFTId
    ) external {
        require(
            isAuthorised(tokenId),
            "ONS_RC: YOU_ARE_NOT_THE_OWNER_OF_THIS_NAME"
        );
        nftResolver.setNFT(tokenId, contractAddress, NFTId, msg.sender);
    }

    /**
     * edit the Verify status of a ONS name using tokenID.
     * Only by ONS admin.
     * @param tokenId of the ONS name.
     * @param status set verify status.
     */
    function editVerifyStatus(uint256 tokenId, bool status) public onlyOwner {
        verifyResolver.verifyONS(tokenId, status, getNameOwner(tokenId));
    }
}
