// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IVerifyResolver {
    event VerifyStatusChanged(
        uint256 indexed tokenId,
        bool indexed status,
        address indexed nameOwner
    );

    /**
     * Returns the status of the ONS name.
     * @param tokenId of the ONS name.
     */
    function checkVerify(uint256 tokenId) external view returns (bool);
}
