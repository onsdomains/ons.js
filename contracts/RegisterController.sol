pragma solidity >=0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ONSRegister.sol";
import "./library/StringUtils.sol";

contract RegisterController is Ownable {
    using StringUtils for *;
    uint256 public constant MIN_REGISTRATION_DURATION = 31536000;

    ONSRegister ons;
    enum WorkflowStatus {
        Before,
        Presale,
        Sale
    }

    WorkflowStatus public workflow;

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
    event WorkflowStatusChange(
        WorkflowStatus previousStatus,
        WorkflowStatus newStatus
    );

    uint256 domainCount;

    constructor(ONSRegister _ons, string memory domain) public {
        transferOwnership(msg.sender);
        ons = _ons;
        domains[domainCount] = Domains(domain, domainCount);
        domainCount++;
        workflow = WorkflowStatus.Before;
    }

    function setUpPresale() external onlyOwner {
        workflow = WorkflowStatus.Presale;
        emit WorkflowStatusChange(
            WorkflowStatus.Before,
            WorkflowStatus.Presale
        );
    }

    function setUpSale() external onlyOwner {
        require(
            workflow == WorkflowStatus.Presale,
            "ONSC: PLEASE_START_THE_PRESALE_FIRST"
        );
        workflow = WorkflowStatus.Sale;
        emit WorkflowStatusChange(WorkflowStatus.Presale, WorkflowStatus.Sale);
    }

    function setDomainPrice(
        uint256[] memory _chalength,
        uint256[] memory _prices
    ) public onlyOwner {
        for (uint256 i = 0; i < _chalength.length; i++) {
            domainPrice[_chalength[i]] = _prices[i];
        }
    }

    function setDiscountPrice(
        uint256[] memory _chalength,
        uint256[] memory _prices
    ) public onlyOwner {
        for (uint256 i = 0; i < _chalength.length; i++) {
            discountPrice[_chalength[i]] = _prices[i];
        }
    }

    function setPresaleListAddress(address[] memory _users) public onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            presaleListedAddresses[_users[i]] = true;
        }
    }

    function verifyUserPresale(address _presaleAddress)
        public
        view
        returns (bool)
    {
        bool userIsPresalelisted = presaleListedAddresses[_presaleAddress];
        return userIsPresalelisted;
    }

    function setFreeMintAddresses(address[] memory _users) public onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            freeMintAddresses[_users[i]] = true;
        }
    }

    function verifyUserFreeMint(address _freeMintAddress)
        public
        view
        returns (bool)
    {
        bool userIsFreeMint = freeMintAddresses[_freeMintAddress];
        return userIsFreeMint;
    }

    function setDiscountAddresses(address[] memory _users) public onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            discountAddresses[_users[i]] = true;
        }
    }

    function verifyUserDiscount(address _discountAddress)
        public
        view
        returns (bool)
    {
        bool userIsDiscount = discountAddresses[_discountAddress];
        return userIsDiscount;
    }

    function addDomain(string memory _name) external onlyOwner {
        domains[domainCount] = Domains(_name, domainCount);
        domainCount++;
        emit AddedDomain(_name, domainCount);
    }

    function getDomain(uint256 _id) public view returns (string memory) {
        return domains[_id].domainName;
    }

    function valid(string memory name) public pure returns (bool) {
        require(checkIsEnglish(name) == true, "ONSC: THE_NAME_MUST_BE_ENGLISH");
        return name.strlen() >= 1 && name.strlen() <= 28;
    }

    function checkIsEnglish(string memory _name) internal pure returns (bool) {
        uint256 i = 0;
        uint256 length = 0;
        bytes memory string_rep = bytes(_name);
        while (i < string_rep.length) {
            uint256 asci = uint256(uint8(string_rep[i]));
            if ((asci >= 48 && asci <= 57) || (asci >= 97 && asci <= 122)) {
                length++;
            } else {
                length = 0;
                break;
            }
            i += 1;
        }

        return length == 0 ? false : true;
    }

    function available(string memory name, uint256 _domainID)
        public
        view
        returns (bool)
    {
        require(valid(name) == true, "ONSC: NAME_IS_NOT_VALID");
        bytes32 label = keccak256(
            bytes.concat(bytes(name), bytes(getDomain(_domainID)))
        );
        return valid(name) && ons.available(uint256(label));
    }

    function expires(string memory name, uint256 _domainID)
        public
        view
        returns (uint256)
    {
        require(valid(name) == true, "ONSC: NAME_IS_NOT_VALID");
        bytes32 label = keccak256(
            bytes.concat(bytes(name), bytes(getDomain(_domainID)))
        );
        return ons.nameExpires(uint256(label));
    }

    function rentPrice(
        string memory name,
        uint256 _domainID,
        uint256 duration,
        address userAddress
    ) public view returns (uint256) {
        require(valid(name) == true, "ONSC: NAME_IS_NOT_VALID");
        if (verifyUserFreeMint(userAddress) && name.strlen() >= 6) {
            return 0;
        } else if (
            verifyUserDiscount(userAddress) || verifyUserPresale(userAddress)
        ) {
            if (name.strlen() == 1) {
                uint256 price = discountPrice[1] * 1 ether;
                return price * duration;
            } else if (name.strlen() == 2) {
                uint256 price = discountPrice[2] * 1 ether;
                return price * duration;
            } else if (name.strlen() == 3) {
                uint256 price = discountPrice[3] * 1 ether;
                return price * duration;
            } else if (name.strlen() == 4) {
                uint256 price = discountPrice[4] * 1 ether;
                return price * duration;
            } else if (name.strlen() == 5) {
                uint256 price = discountPrice[5] * 1 ether;
                return price * duration;
            } else {
                uint256 price = discountPrice[6] * 1 ether;
                return price * duration;
            }
        } else {
            if (name.strlen() == 1) {
                uint256 price = domainPrice[1] * 1 ether;
                return price * duration;
            } else if (name.strlen() == 2) {
                uint256 price = domainPrice[2] * 1 ether;
                return price * duration;
            } else if (name.strlen() == 3) {
                uint256 price = domainPrice[3] * 1 ether;
                return price * duration;
            } else if (name.strlen() == 4) {
                uint256 price = domainPrice[4] * 1 ether;
                return price * duration;
            } else if (name.strlen() == 5) {
                uint256 price = domainPrice[5] * 1 ether;
                return price * duration;
            } else {
                uint256 price = domainPrice[6] * 1 ether;
                return price * duration;
            }
        }
    }

    function register(
        string calldata _name,
        uint256 _domainID,
        uint256 _duration
    ) external payable {
        require(
            workflow == WorkflowStatus.Sale,
            "ONSC: PUBLICSALE_NOT_STARTED_YET"
        );
        require(valid(_name) == true, "ONSC: NAME_IS_NOT_VALID");
        require(available(_name, _domainID), "ONSC: NAME_IS_NOT_AVAILABLE");
        registerWithConfig(_name, _domainID, msg.sender, _duration);
    }

    function presaleRegister(
        string calldata _name,
        uint256 _domainID,
        uint256 _duration
    ) external payable {
        require(
            workflow == WorkflowStatus.Presale,
            "ONSC: PRESALE_NOT_STARTED_YET"
        );
        require(verifyUserPresale(msg.sender), "ONSC: YOU_ARE_NOT_IN_PRESALE!");
        require(valid(_name) == true, "ONSC: NAME_IS_NOT_VALID");
        require(
            available(_name, _domainID) == true,
            "ONSC: NAME_IS_NOT_AVAILABLE"
        );
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
            msg.value >= rentPrice(name, _domainID, duration, owner),
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
            rentPrice(name, _domainID, duration, owner),
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
        } else if (verifyUserPresale(owner)) {
            presaleListedAddresses[owner] = false;
        }
        // Refund any extra payment
        if (msg.value > rentPrice(name, _domainID, duration, owner)) {
            payable(msg.sender).transfer(
                msg.value - rentPrice(name, _domainID, duration, owner)
            );
        }
    }

    function registerOwner(
        string memory name,
        uint256 _domainID,
        uint256 duration
    ) public onlyOwner {
        require(valid(name) == true, "ONSC: NAME_IS_NOT_VALID");
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
            msg.value >= rentPrice(name, _domainID, duration, msg.sender),
            "ONSC: YOU_SENDED_WRONG_VALUE_RENEW"
        );
        uint256 year = duration * 31536000;

        uint256 expires = ons.renew(uint256(label), year);
        if (msg.value > rentPrice(name, _domainID, duration, msg.sender)) {
            payable(msg.sender).transfer(
                msg.value - rentPrice(name, _domainID, duration, msg.sender)
            );
        }
        emit NameRenewed(
            name,
            label,
            rentPrice(name, _domainID, duration, msg.sender),
            expires
        );
    }

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
