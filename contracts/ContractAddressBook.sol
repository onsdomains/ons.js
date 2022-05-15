// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractAddressBook is Ownable {
    struct ContractInformation {
        address contractAddress;
        string contractAbiURI;
    }

    mapping(string => ContractInformation) contracts;
    event ContractAdded(
        string _contractKey,
        string contractAbiURI,
        address _contractAddress
    );

    constructor() public {
        transferOwnership(msg.sender);
    }

    /**
     * Add contract address to the Contract Book
     * @param _contractKey contract name.
     * @param _contractAddress Contract address.
     * @param _contractABIURI Contract ABI URI.
     */
    function setContractAddress(
        string memory _contractKey,
        string memory _contractABIURI,
        address _contractAddress
    ) public onlyOwner {
        ContractInformation storage _ContractInformation = contracts[
            _contractKey
        ];
        _ContractInformation.contractAddress = _contractAddress;
        _ContractInformation.contractAbiURI = _contractABIURI;
        emit ContractAdded(_contractKey, _contractABIURI, _contractAddress);
    }

    /**
     * Add Multi contract address to the Contract Book
     * @param _contractKey contract names.
     * @param _contractAddress Contract addresses.
     * @param _contractABIURI Contract ABIs URI.
     */
    function setMultiContractAddress(
        string[] memory _contractKey,
        string[] memory _contractABIURI,
        address[] memory _contractAddress
    ) public onlyOwner {
        for (uint256 i = 0; i < _contractKey.length; i++) {
            ContractInformation storage _ContractInformation = contracts[
                _contractKey[i]
            ];
            _ContractInformation.contractAddress = _contractAddress[i];
            _ContractInformation.contractAbiURI = _contractABIURI[i];
            emit ContractAdded(
                _contractKey[i],
                _contractABIURI[i],
                _contractAddress[i]
            );
        }
    }

    /**
     * Returns the address of contract by name.
     * @param _contractKey contract name.
     */
    function getContractAddress(string memory _contractKey)
        external
        view
        returns (address)
    {
        ContractInformation storage _ContractInformation = contracts[
            _contractKey
        ];
        return _ContractInformation.contractAddress;
    }

    /**
     * Returns the address of contract by name.
     * @param _contractKey contract name.
     */
    function getContractABI(string memory _contractKey)
        external
        view
        returns (string memory)
    {
        ContractInformation storage _ContractInformation = contracts[
            _contractKey
        ];
        return _ContractInformation.contractAbiURI;
    }
}
