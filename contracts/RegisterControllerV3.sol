// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
/**
░█████╗░███╗░░██╗░██████╗
██╔══██╗████╗░██║██╔════╝
██║░░██║██╔██╗██║╚█████╗░
██║░░██║██║╚████║░╚═══██╗
╚█████╔╝██║░╚███║██████╔╝
░╚════╝░╚═╝░░╚══╝╚═════╝░
*/
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ONSRegister.sol";
import "./helper/TopLevelDomain.sol";
import "./helper/ListsController.sol";
import "./library/StringUtils.sol";

contract RegisterControllerV3 is Ownable {
    using StringUtils for *;
    uint256 public constant MIN_REGISTRATION_DURATION = 31536000;

    event NameRegistered(
        string name,
        uint256 domainID,
        bytes32 indexed label,
        address indexed owner,
        uint256 cost,
        uint256 expires
    );
    event NameRenewed(
        string name,
        bytes32 indexed label,
        uint256 cost,
        uint256 expires
    );

    ONSRegister ons;
    TopLevelDomain topLevelDomain;
    ListsController listsController;

    constructor(
        ONSRegister _ons,
        TopLevelDomain _topLevelDomain,
        ListsController _listsController
    ) public {
        transferOwnership(msg.sender);
        ons = _ons;
        topLevelDomain = _topLevelDomain;
        listsController = _listsController;
    }

    /**
     * set the Main List Controller
     * @param _listsController: address of the List Controller contract.
     */
    function setListsController(ListsController _listsController)
        public
        onlyOwner
    {
        listsController = _listsController;
    }

    /**
     * set the Main List Controller
     * @param _topLevelDomain: address of the List Controller contract.
     */
    function setTopLevelDomain(TopLevelDomain _topLevelDomain)
        public
        onlyOwner
    {
        topLevelDomain = _topLevelDomain;
    }

    /**
     * check if the Name is English and in lowercase
     * @param _name: The Name.
     */
    function checkAlphanumeric(string memory _name)
        internal
        pure
        returns (bool)
    {
        bytes memory b = bytes(_name);

        for (uint256 i; i < b.length; i++) {
            bytes1 char = b[i];

            if (
                !(char >= 0x30 && char <= 0x39) && //9-0
                !(char >= 0x61 && char <= 0x7A) //a-z
            ) return false;
        }

        return true;
    }

    /**
     * check if the Name is Valid (he need to be bigger than 0 and smaller than 29)
     * @param _name: The Name.
     */
    function valid(string memory _name) public pure returns (bool) {
        require(checkAlphanumeric(_name), "ONSC: THE_NAME_MUST_BE_ENGLISH");
        return _name.strlen() >= 1 && _name.strlen() <= 28;
    }

    /**
     * check if the Name is available
     * @param _name: The Name.
     * @param _domainID: The ID of the domain (example: 0 for .ons).
     */
    function available(string memory _name, uint256 _domainID)
        public
        view
        returns (bool)
    {
        require(valid(_name), "ONSC: NAME_IS_NOT_VALID");
        bytes32 label = keccak256(
            bytes.concat(
                bytes(_name),
                bytes(topLevelDomain.getDomain(_domainID))
            )
        );
        return ons.available(uint256(label));
    }

    /**
     * convert string to ID
     * @param _name: The Name.
     */
    function getDomainID(string memory _name) public view returns (uint256) {
        bytes32 label = keccak256(bytes(_name));
        return uint256(label);
    }

    /**
     * get expire date of the Name
     * @param _name: The Name.
     * @param _domainID: The ID of the domain (example: 0 for .ons).
     */
    function expires(string memory _name, uint256 _domainID)
        public
        view
        returns (uint256)
    {
        require(valid(_name), "ONSC: NAME_IS_NOT_VALID");
        bytes32 label = keccak256(
            bytes.concat(
                bytes(_name),
                bytes(topLevelDomain.getDomain(_domainID))
            )
        );
        return ons.nameExpires(uint256(label));
    }

    /**
     * get rent price for the Name
     * @param _name: The Name.
     * @param _domainID: The ID of the domain (example: 0 for .ons).
     * @param _duration The duration of domain in years.
     * @param _userAddress: Address of the buyer.
     * @param _isSale: check if it called from sale.
     */
    function rentPrice(
        string memory _name,
        uint256 _domainID,
        uint256 _duration,
        address _userAddress,
        bool _isSale
    ) public view returns (uint256) {
        require(valid(_name), "ONSC: NAME_IS_NOT_VALID");
        if (_isSale) {
            if (
                listsController.verifyUserFreeMint(_userAddress) &&
                _name.strlen() >= 6
            ) {
                return 0;
            } else if (listsController.verifyUserDiscount(_userAddress)) {
                uint256 priceIdx = _name.strlen() > 5 ? 6 : _name.strlen();
                return
                    listsController.getDiscountPrice(_domainID, priceIdx) *
                    1 ether *
                    _duration;
            } else {
                uint256 priceIdx = _name.strlen() > 5 ? 6 : _name.strlen();
                return
                    listsController.getDomainPrice(_domainID, priceIdx) *
                    1 ether *
                    _duration;
            }
        } else {
            uint256 priceIdx = _name.strlen() > 5 ? 6 : _name.strlen();
            return
                listsController.getDomainPrice(_domainID, priceIdx) *
                1 ether *
                _duration;
        }
    }

    /**
     * Register a name that's not currently registered
     * @param _name The name to register.
     * @param _domainID The ID of the domain (example: 0 for .ons).
     * @param _duration The duration of domain in years.
     */
    function register(
        string calldata _name,
        uint256 _domainID,
        uint256 _duration
    ) external payable {
        require(valid(_name), "ONSC: NAME_IS_NOT_VALID");
        require(available(_name, _domainID), "ONSC: NAME_IS_NOT_AVAILABLE");
        registerWithConfig(_name, _domainID, msg.sender, _duration);
    }

    function registerWithConfig(
        string memory _name,
        uint256 _domainID,
        address _owner,
        uint256 _duration
    ) internal {
        uint256 year = _duration * 31536000;
        require(
            year >= MIN_REGISTRATION_DURATION,
            "ONSC: MIN_REGISTRATION_DURATION_IS_YEAR"
        );
        require(
            msg.value >= rentPrice(_name, _domainID, _duration, _owner, true),
            "ONSC: YOU_SENDED_WRONG_VALUE"
        );
        bytes32 label = keccak256(
            bytes.concat(
                bytes(_name),
                bytes(topLevelDomain.getDomain(_domainID))
            )
        );
        uint256 tokenId = uint256(label);

        uint256 expires = ons.register(
            tokenId,
            string(
                abi.encodePacked(_name, topLevelDomain.getDomain(_domainID))
            ),
            _owner,
            year
        );
        emit NameRegistered(
            _name,
            _domainID,
            label,
            _owner,
            rentPrice(_name, _domainID, _duration, _owner, true),
            expires
        );
        if (ons.balanceOf(_owner) == 1) {
            require(
                ons.ownerOf(uint256(label)) == _owner,
                "ONSC: YOU_ARE_NOT_THE_OWNER_OF_THIS_NAME"
            );
            string memory name = string(
                abi.encodePacked(_name, topLevelDomain.getDomain(_domainID))
            );
            ons.setName(name, _owner);
        }
        if (listsController.verifyUserFreeMint(_owner)) {
            listsController.unsetFreeMintAddresses(_owner);
        } else if (listsController.verifyUserDiscount(_owner)) {
            listsController.unsetDiscountAddresses(_owner);
        }
        // Refund any extra payment
        if (msg.value > rentPrice(_name, _domainID, _duration, _owner, true)) {
            payable(msg.sender).transfer(
                msg.value - rentPrice(_name, _domainID, _duration, _owner, true)
            );
        }
    }

    /**
     * Register a name that's not currently registered (by owner)
     * @param _name: The name to register.
     * @param _domainID: The ID of the domain (example: 0 for .ons).
     * @param _duration: The duration of domain in years.
     */
    function registerOwner(
        string memory _name,
        uint256 _domainID,
        uint256 _duration
    ) public onlyOwner {
        require(valid(_name), "ONSC: NAME_IS_NOT_VALID");
        require(available(_name, _domainID), "ONSC: NAME_IS_NOT_AVAILABLE");
        uint256 year = _duration * 31536000;
        require(
            year >= MIN_REGISTRATION_DURATION,
            "ONSC: MIN_REGISTRATION_DURATION_IS_YEAR"
        );
        bytes32 label = keccak256(
            bytes.concat(
                bytes(_name),
                bytes(topLevelDomain.getDomain(_domainID))
            )
        );
        uint256 tokenId = uint256(label);
        uint256 expires = ons.register(
            tokenId,
            string(
                abi.encodePacked(_name, topLevelDomain.getDomain(_domainID))
            ),
            msg.sender,
            year
        );
        emit NameRegistered(_name, _domainID, label, msg.sender, 0, expires);
        if (ons.balanceOf(msg.sender) == 1) {
            require(
                ons.ownerOf(uint256(label)) == msg.sender,
                "ONSC: YOU_ARE_NOT_THE_OWNER_OF_THIS_NAME"
            );
            string memory name = string(
                abi.encodePacked(_name, topLevelDomain.getDomain(_domainID))
            );
            ons.setName(name, msg.sender);
        }
    }

    /**
     * renew name just by owner of the name
     * @param _name The name to renew.
     * @param _domainID The ID of the domain (example: 0 for .ons).
     * @param _duration The duration to renew the Domain in years.
     */
    function renew(
        string memory _name,
        uint256 _domainID,
        uint256 _duration
    ) external payable {
        bytes32 label = keccak256(
            bytes.concat(
                bytes(_name),
                bytes(topLevelDomain.getDomain(_domainID))
            )
        );
        require(
            ons.ownerOf(uint256(label)) == msg.sender,
            "ONSC: YOU_ARE_NOT_THE_OWNER_OF_THIS_NAME"
        );
        require(
            msg.value >=
                rentPrice(_name, _domainID, _duration, msg.sender, false),
            "ONSC: YOU_SENDED_WRONG_VALUE_RENEW"
        );
        uint256 year = _duration * 31536000;

        uint256 expires = ons.renew(uint256(label), year);
        if (
            msg.value >
            rentPrice(_name, _domainID, _duration, msg.sender, false)
        ) {
            payable(msg.sender).transfer(
                msg.value -
                    rentPrice(_name, _domainID, _duration, msg.sender, false)
            );
        }
        emit NameRenewed(
            _name,
            label,
            rentPrice(_name, _domainID, _duration, msg.sender, false),
            expires
        );
    }

    /**
     * set name as Primary
     * @param _name The name to register.
     * @param _domainID The ID of the domain (example: 0 for .ons).
     */
    function setName(string memory _name, uint256 _domainID) external {
        bytes32 label = keccak256(
            bytes.concat(
                bytes(_name),
                bytes(topLevelDomain.getDomain(_domainID))
            )
        );
        require(
            ons.ownerOf(uint256(label)) == msg.sender,
            "ONSC: YOU_ARE_NOT_THE_OWNER_OF_THIS_NAME"
        );
        string memory name = string(
            abi.encodePacked(_name, topLevelDomain.getDomain(_domainID))
        );
        ons.setName(name, msg.sender);
    }

    /**
     * unset name from Primary
     * @param _name The name to register.
     * @param _domainID The ID of the domain (example: 0 for .ons).
     */
    function unsetName(string memory _name, uint256 _domainID) external {
        bytes32 label = keccak256(
            bytes.concat(
                bytes(_name),
                bytes(topLevelDomain.getDomain(_domainID))
            )
        );
        require(
            ons.ownerOf(uint256(label)) == msg.sender,
            "ONSC: YOU_ARE_NOT_THE_OWNER_OF_THIS_NAME"
        );
        ons.unsetName(msg.sender);
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
