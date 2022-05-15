interface contractInterface {
    abi: Object[],
}
const PublicResolver: contractInterface = {
    abi: [
        {
            "inputs": [
                {
                    "internalType": "contract ONSRegister",
                    "name": "_ons",
                    "type": "address"
                },
                {
                    "internalType": "contract TextResolver",
                    "name": "_textResolver",
                    "type": "address"
                },
                {
                    "internalType": "contract NFTResolver",
                    "name": "_nftResolver",
                    "type": "address"
                },
                {
                    "internalType": "contract VerifyResolver",
                    "name": "_verifyResolver",
                    "type": "address"
                },
                {
                    "internalType": "contract TextFilters",
                    "name": "_textFilters",
                    "type": "address"
                }
            ],
            "stateMutability": "nonpayable",
            "type": "constructor"
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
                    "internalType": "uint256",
                    "name": "tokenId",
                    "type": "uint256"
                },
                {
                    "internalType": "contract ABIHelper",
                    "name": "contractAddress",
                    "type": "address"
                },
                {
                    "internalType": "uint256",
                    "name": "NFTId",
                    "type": "uint256"
                }
            ],
            "name": "editNFT",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "tokenId",
                    "type": "uint256"
                },
                {
                    "internalType": "string",
                    "name": "key",
                    "type": "string"
                },
                {
                    "internalType": "string",
                    "name": "value",
                    "type": "string"
                }
            ],
            "name": "editText",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "tokenId",
                    "type": "uint256"
                },
                {
                    "internalType": "bool",
                    "name": "status",
                    "type": "bool"
                }
            ],
            "name": "editVerifyStatus",
            "outputs": [],
            "stateMutability": "nonpayable",
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
export default PublicResolver;
