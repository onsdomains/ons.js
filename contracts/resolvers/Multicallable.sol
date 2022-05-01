// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IMulticallable.sol";

abstract contract Multicallable is IMulticallable {
    /**
     * edit multiple data of a token.
     * May only be called by the owner of that Name.
     * @param data data in array
     */

    function multicall(bytes[] calldata data)
        external
        override
        returns (bytes[] memory results)
    {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(
                data[i]
            );
            require(success);
            results[i] = result;
        }
        return results;
    }
}
