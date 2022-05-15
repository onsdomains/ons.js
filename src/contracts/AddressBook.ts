interface contractInterface {
    abi: Object[],
    address: string,
}
const AddressBook: contractInterface = {
    address: '0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6',
    abi: [
        {
            "inputs": [],
            "stateMutability": "nonpayable",
            "type": "constructor"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": false,
                    "internalType": "string",
                    "name": "_contractKey",
                    "type": "string"
                },
                {
                    "indexed": false,
                    "internalType": "string",
                    "name": "contractAbiURI",
                    "type": "string"
                },
                {
                    "indexed": false,
                    "internalType": "address",
                    "name": "_contractAddress",
                    "type": "address"
                }
            ],
            "name": "ContractAdded",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": true,
                    "internalType": "address",
                    "name": "previousOwner",
                    "type": "address"
                },
                {
                    "indexed": true,
                    "internalType": "address",
                    "name": "newOwner",
                    "type": "address"
                }
            ],
            "name": "OwnershipTransferred",
            "type": "event"
        },
        {
            "inputs": [
                {
                    "internalType": "string",
                    "name": "_contractKey",
                    "type": "string"
                }
            ],
            "name": "getContractABI",
            "outputs": [
                {
                    "internalType": "string",
                    "name": "",
                    "type": "string"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "string",
                    "name": "_contractKey",
                    "type": "string"
                }
            ],
            "name": "getContractAddress",
            "outputs": [
                {
                    "internalType": "address",
                    "name": "",
                    "type": "address"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "owner",
            "outputs": [
                {
                    "internalType": "address",
                    "name": "",
                    "type": "address"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "renounceOwnership",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "string",
                    "name": "_contractKey",
                    "type": "string"
                },
                {
                    "internalType": "string",
                    "name": "_contractABIURI",
                    "type": "string"
                },
                {
                    "internalType": "address",
                    "name": "_contractAddress",
                    "type": "address"
                }
            ],
            "name": "setContractAddress",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "string[]",
                    "name": "_contractKey",
                    "type": "string[]"
                },
                {
                    "internalType": "string[]",
                    "name": "_contractABIURI",
                    "type": "string[]"
                },
                {
                    "internalType": "address[]",
                    "name": "_contractAddress",
                    "type": "address[]"
                }
            ],
            "name": "setMultiContractAddress",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "newOwner",
                    "type": "address"
                }
            ],
            "name": "transferOwnership",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        }
    ],
};
export default AddressBook;
