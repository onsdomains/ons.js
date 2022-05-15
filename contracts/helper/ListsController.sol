// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../AdminController.sol";

contract ListsController is Ownable, AdminController {
    AdminController adminController;

    mapping(address => bool) discountAddresses;
    mapping(address => bool) freeMintAddresses;
    mapping(uint256 => mapping(uint256 => uint256)) domainPrice;
    mapping(uint256 => mapping(uint256 => uint256)) discountPrice;

    constructor(AdminController _adminController) public {
        transferOwnership(msg.sender);
        adminController = _adminController;
    }

    modifier onlyController() {
        require(
            adminController.adminControllers(msg.sender),
            "ONS NFT_Resolver: YOU_HAVE_NO_PROMOTIONS"
        );
        _;
    }

    /**
     * set the Main name price
     * @param _domainID: The ID of the domain (example: 0 for .ons).
     * @param _chalength[]: cha length.
     * @param _prices[]: price of the Name.
     */
    function setDomainPrice(
        uint256 _domainID,
        uint256[] memory _chalength,
        uint256[] memory _prices
    ) public onlyOwner {
        for (uint256 i = 0; i < _chalength.length; i++) {
            domainPrice[_domainID][_chalength[i]] = _prices[i];
        }
    }

    /**
     * get the name price
     * @param _domainID: The ID of the domain (example: 0 for .ons).
     * @param _chalength: cha length.
     */
    function getDomainPrice(uint256 _domainID, uint256 _chalength)
        public
        view
        returns (uint256)
    {
        uint256 _domainPrice = domainPrice[_domainID][_chalength];
        return _domainPrice;
    }

    /**
     * set the Discount name price
     * @param _domainID: The ID of the domain (example: 0 for .ons).
     * @param _chalength[]: cha length.
     * @param _prices[]: price of the Name.
     */
    function setDiscountPrice(
        uint256 _domainID,
        uint256[] memory _chalength,
        uint256[] memory _prices
    ) public onlyOwner {
        for (uint256 i = 0; i < _chalength.length; i++) {
            discountPrice[_domainID][_chalength[i]] = _prices[i];
        }
    }

    /**
     * get the Discount name price
     * @param _domainID: The ID of the domain (example: 0 for .ons).
     * @param _chalength: cha length.
     */
    function getDiscountPrice(uint256 _domainID, uint256 _chalength)
        public
        view
        returns (uint256)
    {
        uint256 _discountPrice = discountPrice[_domainID][_chalength];
        return _discountPrice;
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
     * remove user from the Free list
     * @param _user: address of the User.
     */
    function unsetFreeMintAddresses(address _user)
        external
        virtual
        onlyController
    {
        require(
            freeMintAddresses[_user],
            "ONS ListsController: THIS_ADDRESS_IS_NOT_IN_THIS_LIST"
        );
        freeMintAddresses[_user] = false;
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
     * remove user from the Discount list
     * @param _user: address of the User.
     */
    function unsetDiscountAddresses(address _user)
        external
        virtual
        onlyController
    {
        require(
            discountAddresses[_user],
            "ONS ListsController: THIS_ADDRESS_IS_NOT_IN_THIS_LIST"
        );
        discountAddresses[_user] = false;
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
}
