// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../helper/ABIHelper.sol";

contract INFTResolver {
    event NFTChanged(
        uint256 indexed tokenId,
        ABIHelper contractAddress,
        uint256 NFTId
    );

    /**
     * ownership checking.
     * @param _caller the address of the Owner.
     * @param _contract the NFT contract address.
     * @param _NFTId TokenID of the NFT.
     */
    function isOwner(
        address _caller,
        ABIHelper _contract,
        uint256 _NFTId
    ) internal view returns (bool) {
        return
            _contract.ownerOf(_NFTId) == _caller ||
            _contract.balanceOf(_caller, _NFTId) != 0;
    }
}
