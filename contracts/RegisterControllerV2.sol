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
import "./library/StringUtils.sol";

contract RegisterControllerV2 is Ownable {
    using StringUtils for *;
    uint256 public constant MIN_REGISTRATION_DURATION = 31536000;
    ONSRegister ons;
    struct Domains {
        string domainName;
        uint256 domainID;
    }
    mapping(uint256 => Domains) public domains;
    mapping(address => bool) presaleListedAddresses;
    mapping(address => bool) discountAddresses;
    mapping(address => bool) freeMintAddresses;
    mapping(uint256 => uint256) domainPrice;
    mapping(uint256 => uint256) discountPrice;

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
    event AddedDomain(string name, uint256 id);

    uint256 domainCount;

    constructor(ONSRegister _ons, string memory domain) public {
        transferOwnership(msg.sender);
        ons = _ons;
        domains[domainCount] = Domains(domain, domainCount);
        domainCount++;
    }

    /**
     * set the Main name price
     * @param _chalength[]: cha length.
     * @param _prices[]: price of the Name.
     */
    function setDomainPrice(
        uint256[] memory _chalength,
        uint256[] memory _prices
    ) public onlyOwner {
        for (uint256 i = 0; i < _chalength.length; i++) {
            domainPrice[_chalength[i]] = _prices[i];
        }
    }

    /**
     * set the Discount name price
     * @param _chalength[]: cha length.
     * @param _prices[]: price of the Name.
     */
    function setDiscountPrice(
        uint256[] memory _chalength,
        uint256[] memory _prices
    ) public onlyOwner {
        for (uint256 i = 0; i < _chalength.length; i++) {
            discountPrice[_chalength[i]] = _prices[i];
        }
    }

    /**
     * add users to the Free list
     * @param _users[]: address list of the Users.
     */
    function setFreeMintAddresses(address[] memory _users) public onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            freeMintAddresses[_users[i]] = true;
        }
    }

    /**
     * check if user is in Free list
     * @param _freeMintAddress: address of the User.
     */
    function verifyUserFreeMint(address _freeMintAddress)
        public
        view
        returns (bool)
    {
        bool userIsFreeMint = freeMintAddresses[_freeMintAddress];
        return userIsFreeMint;
    }

    /**
     * add users to the Discount list
     * @param _users[]: address list of the Users.
     */
    function setDiscountAddresses(address[] memory _users) public onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            discountAddresses[_users[i]] = true;
        }
    }

    /**
     * check if user is in Discount list
     * @param _discountAddress: address of the User.
     */
    function verifyUserDiscount(address _discountAddress)
        public
        view
        returns (bool)
    {
        bool userIsDiscount = discountAddresses[_discountAddress];
        return userIsDiscount;
    }

    /**
     * add a Top Domain to the List
     * @param _name: The name which should be added.
     */
    function addDomain(string memory _name) external onlyOwner {
        domains[domainCount] = Domains(_name, domainCount);
        domainCount++;
        emit AddedDomain(_name, domainCount);
    }

    /**
     * get the Top Domain using ID
     * @param _id: the ID of the Top Domain.
     */
    function getDomain(uint256 _id) public view returns (string memory) {
        return domains[_id].domainName;
    }

    /**
     * check if the Name is Valid (he need to be bigger than 0 and smaller than 29)
     * @param name: The Name.
     */
    function valid(string memory name) public pure returns (bool) {
        require(checkAlphanumeric(name), "ONSC: THE_NAME_MUST_BE_ENGLISH");
        return name.strlen() >= 1 && name.strlen() <= 28;
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
     * check if the Name is available
     * @param name: The Name.
     * @param _domainID: The ID of the domain (example: 0 for .ons).
     */
    function available(string memory name, uint256 _domainID)
        public
        view
        returns (bool)
    {
        require(valid(name), "ONSC: NAME_IS_NOT_VALID");
        bytes32 label = keccak256(
            bytes.concat(bytes(name), bytes(getDomain(_domainID)))
        );
        return ons.available(uint256(label));
    }

    /**
     * get expire date of the Name
     * @param name: The Name.
     * @param _domainID: The ID of the domain (example: 0 for .ons).
     */
    function expires(string memory name, uint256 _domainID)
        public
        view
        returns (uint256)
    {
        require(valid(name), "ONSC: NAME_IS_NOT_VALID");
        bytes32 label = keccak256(
            bytes.concat(bytes(name), bytes(getDomain(_domainID)))
        );
        return ons.nameExpires(uint256(label));
    }

    /**
     * get rent price for the Name
     * @param name: The Name.
     * @param _domainID: The ID of the domain (example: 0 for .ons).
     * @param duration The duration of domain in years.
     * @param userAddress: Address of the buyer.
     * @param isSale: check if it called from sale.
     */
    function rentPrice(
        string memory name,
        uint256 _domainID,
        uint256 duration,
        address userAddress,
        bool isSale
    ) public view returns (uint256) {
        require(valid(name), "ONSC: NAME_IS_NOT_VALID");
        if (isSale) {
            if (verifyUserFreeMint(userAddress) && name.strlen() >= 6) {
                return 0;
            } else if (verifyUserDiscount(userAddress)) {
                uint256 priceIdx = name.strlen() > 5 ? 6 : name.strlen();
                return discountPrice[priceIdx] * 1 ether * duration;
            } else {
                uint256 priceIdx = name.strlen() > 5 ? 6 : name.strlen();
                return domainPrice[priceIdx] * 1 ether * duration;
            }
        } else {
            uint256 priceIdx = name.strlen() > 5 ? 6 : name.strlen();
            return domainPrice[priceIdx] * 1 ether * duration;
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
        string memory name,
        uint256 _domainID,
        address owner,
        uint256 duration
    ) internal {
        uint256 year = duration * 31536000;
        require(
            year >= MIN_REGISTRATION_DURATION,
            "ONSC: MIN_REGISTRATION_DURATION_IS_YEAR"
        );
        require(
            msg.value >= rentPrice(name, _domainID, duration, owner, true),
            "ONSC: YOU_SENDED_WRONG_VALUE"
        );
        bytes32 label = keccak256(
            bytes.concat(bytes(name), bytes(getDomain(_domainID)))
        );
        uint256 tokenId = uint256(label);

        uint256 expires = ons.register(
            tokenId,
            string(abi.encodePacked(name, getDomain(_domainID))),
            owner,
            year
        );
        emit NameRegistered(
            name,
            _domainID,
            label,
            owner,
            rentPrice(name, _domainID, duration, owner, true),
            expires
        );
        if (ons.balanceOf(owner) == 1) {
            require(
                ons.ownerOf(uint256(label)) == owner,
                "ONSC: YOU_ARE_NOT_THE_OWNER_OF_THIS_NAME"
            );
            string memory _name = string(
                abi.encodePacked(name, getDomain(_domainID))
            );
            ons.setName(_name, owner);
        }
        if (verifyUserFreeMint(owner)) {
            freeMintAddresses[owner] = false;
        } else if (verifyUserDiscount(owner)) {
            discountAddresses[owner] = false;
        }
        // Refund any extra payment
        if (msg.value > rentPrice(name, _domainID, duration, owner, true)) {
            payable(msg.sender).transfer(
                msg.value - rentPrice(name, _domainID, duration, owner, true)
            );
        }
    }

    /**
     * Register a name that's not currently registered (by owner)
     * @param name: The name to register.
     * @param _domainID: The ID of the domain (example: 0 for .ons).
     * @param duration: The duration of domain in years.
     */
    function registerOwner(
        string memory name,
        uint256 _domainID,
        uint256 duration
    ) public onlyOwner {
        require(valid(name), "ONSC: NAME_IS_NOT_VALID");
        require(available(name, _domainID), "ONSC: NAME_IS_NOT_AVAILABLE");
        uint256 year = duration * 31536000;
        require(
            year >= MIN_REGISTRATION_DURATION,
            "ONSC: MIN_REGISTRATION_DURATION_IS_YEAR"
        );
        bytes32 label = keccak256(
            bytes.concat(bytes(name), bytes(getDomain(_domainID)))
        );
        uint256 tokenId = uint256(label);
        uint256 expires = ons.register(
            tokenId,
            string(abi.encodePacked(name, getDomain(_domainID))),
            msg.sender,
            year
        );
        emit NameRegistered(name, _domainID, label, msg.sender, 0, expires);
        if (ons.balanceOf(msg.sender) == 1) {
            require(
                ons.ownerOf(uint256(label)) == msg.sender,
                "ONSC: YOU_ARE_NOT_THE_OWNER_OF_THIS_NAME"
            );
            string memory _name = string(
                abi.encodePacked(name, getDomain(_domainID))
            );
            ons.setName(_name, msg.sender);
        }
    }

    /**
     * renew name just by owner of the name
     * @param name The name to renew.
     * @param _domainID The ID of the domain (example: 0 for .ons).
     * @param duration The duration to renew the Domain in years.
     */
    function renew(
        string memory name,
        uint256 _domainID,
        uint256 duration
    ) external payable {
        bytes32 label = keccak256(
            bytes.concat(bytes(name), bytes(getDomain(_domainID)))
        );
        require(
            ons.ownerOf(uint256(label)) == msg.sender,
            "ONSC: YOU_ARE_NOT_THE_OWNER_OF_THIS_NAME"
        );
        require(
            msg.value >=
                rentPrice(name, _domainID, duration, msg.sender, false),
            "ONSC: YOU_SENDED_WRONG_VALUE_RENEW"
        );
        uint256 year = duration * 31536000;

        uint256 expires = ons.renew(uint256(label), year);
        if (
            msg.value > rentPrice(name, _domainID, duration, msg.sender, false)
        ) {
            payable(msg.sender).transfer(
                msg.value -
                    rentPrice(name, _domainID, duration, msg.sender, false)
            );
        }
        emit NameRenewed(
            name,
            label,
            rentPrice(name, _domainID, duration, msg.sender, false),
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
            bytes.concat(bytes(_name), bytes(getDomain(_domainID)))
        );
        require(
            ons.ownerOf(uint256(label)) == msg.sender,
            "ONSC: YOU_ARE_NOT_THE_OWNER_OF_THIS_NAME"
        );
        string memory name = string(
            abi.encodePacked(_name, getDomain(_domainID))
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
            bytes.concat(bytes(_name), bytes(getDomain(_domainID)))
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
