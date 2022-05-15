// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "./INFTResolver.sol";
import "../ResolverController.sol";
import "../../ONSRegister.sol";

contract NFTResolver is INFTResolver, ResolverController {
    struct NFTDetails {
        ABIHelper contractAddress;
        uint256 tokenID;
    }

    mapping(uint256 => NFTDetails) NFTS;

    ResolverController RC;
    ONSRegister ons;

    constructor(ONSRegister _ons, ResolverController _rc) public {
        RC = _rc;
        ons = _ons;
    }

    modifier onlyController() {
        require(
            RC.controllers(msg.sender),
            "ONS NFT_Resolver: YOU_HAVE_NO_PROMOTIONS"
        );
        _;
    }

    /**
     * Sets the NFT as ONS Avatar using ONS tokenId.
     * May only be called by the owner of that Name.
     * @param tokenId of the ONS name.
     * @param _contract the NFT contract address.
     * @param _NFTId TokenID of the NFT.
     * @param _caller the address of ons Owner.
     */
    function setNFT(
        uint256 tokenId,
        ABIHelper _contract,
        uint256 _NFTId,
        address _caller
    ) external virtual onlyController {
        require(
            isOwner(_caller, _contract, _NFTId),
            "ONS NFT_Resolver: YOU_ARE_NOT_THE_OWNER_OF_THIS_NFT"
        );

        NFTDetails storage _NFTDetails = NFTS[tokenId];
        _NFTDetails.tokenID = _NFTId;
        _NFTDetails.contractAddress = _contract;

        emit NFTChanged(tokenId, _contract, _NFTId);
    }

    /**
     * Returns the NFT data using an ONS TokenID.
     * @param tokenId of the ONS name.
     */
    function NFT(uint256 tokenId)
        external
        view
        virtual
        returns (NFTDetails memory)
    {
        address onsOwner = ons.ownerOf(tokenId);
        NFTDetails storage _NFTDetails = NFTS[tokenId];
        require(
            isOwner(onsOwner, _NFTDetails.contractAddress, _NFTDetails.tokenID),
            "ONS NFT_Resolver: THIS_NFT_IS_NOT_ANYMORE_VALID_FOR_THIS_NAME"
        );
        return _NFTDetails;
    }
    /**
    * Returns the URI of the token.
    * @param tokenId of the ONS name.
     */
    function getTokenURI(uint256 tokenId)
    external
    view
    virtual
    returns (string memory)
    {
        address onsOwner = ons.ownerOf(tokenId);
        NFTDetails storage _NFTDetails = NFTS[tokenId];
        require(
            isOwner(onsOwner, _NFTDetails.contractAddress, _NFTDetails.tokenID),
            "ONS NFT_Resolver: THIS_NFT_IS_NOT_ANYMORE_VALID_FOR_THIS_NAME"
        );
        string memory _tokenURI = _NFTDetails.contractAddress.tokenURI(_NFTDetails.tokenID);
        return _tokenURI;
    }

}
