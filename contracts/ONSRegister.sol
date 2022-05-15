// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BaseRegister.sol";

contract ONSRegister is ERC721Enumerable, BaseRegister {
    /**
     * Map pf expiry times
     */
    mapping(uint256 => uint256) public expiries;
    mapping(address => string) public primaryName;
    mapping(uint256 => string) public doamins;

    constructor() ERC721("Oasis Name Service", "ONS") {}

    /**
     *    setBaseURI
     */
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    /**
     *    is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        override
        returns (bool)
    {
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    /**
     *   owner of the token
     */
    function ownerOf(uint256 tokenId)
        public
        view
        override(IERC721, ERC721)
        returns (address)
    {
        require(expiries[tokenId] > block.timestamp);
        return super.ownerOf(tokenId);
    }

    /**
     *  return when the name expires
     */
    function nameExpires(uint256 id) external view override returns (uint256) {
        return expiries[id];
    }

    modifier onlyController() {
        require(controllers[msg.sender]);
        _;
    }

    /**
     *  add who can register and renew domains.
     */
    function addController(address controller) external override onlyOwner {
        controllers[controller] = true;
        emit ControllerAdded(controller);
    }

    /**
     *  remove who can register and renew domains.
     */
    function removeController(address controller) external override onlyOwner {
        controllers[controller] = false;
        emit ControllerRemoved(controller);
    }

    /**
     *  Check if token is available
     */
    function available(uint256 id) public view override returns (bool) {
        return expiries[id] + GRACE_PERIOD < block.timestamp;
    }

    /**
     * external
     *  register a name using keccak256
     */
    function register(
        uint256 id,
        string memory name,
        address owner,
        uint256 duration
    ) external override returns (uint256) {
        return _register(id, name, owner, duration);
    }

    /**
     * internal
     *  register a name using keccak256
     */
    function _register(
        uint256 id,
        string memory name,
        address owner,
        uint256 duration
    ) internal onlyController returns (uint256) {
        require(available(id), "ONS: ID_NOT_AVAILABLE");
        require(
            block.timestamp + duration + GRACE_PERIOD >
                block.timestamp + GRACE_PERIOD,
            "ONS: TIME_PROBLEM!"
        ); // Prevent future overflow
        expiries[id] = block.timestamp + duration;

        if (_exists(id)) {
            delete primaryName[super.ownerOf(id)];
            _burn(id);
        }
        _mint(owner, id);
        doamins[id] = name;

        emit NameRegistered(id, owner, block.timestamp + duration);
        return block.timestamp + duration;
    }

    /**
     *  renew token expiries
     */
    function renew(uint256 id, uint256 duration)
        external
        override
        onlyController
        returns (uint256)
    {
        require(
            expiries[id] + GRACE_PERIOD >= block.timestamp,
            "ONS: TIME_IS_LOWER_THAN_NOW "
        );
        require(
            expiries[id] + duration + GRACE_PERIOD > duration + GRACE_PERIOD,
            "ONS: TIME_PROBLEM_LOWER!"
        );
        expiries[id] += duration;
        emit NameRenewed(id, expiries[id]);
        return expiries[id];
    }

    /**
     *  set primary name
     */
    function setName(string memory _name, address _owner)
        external
        onlyController
        returns (string memory)
    {
        primaryName[_owner] = _name;
        return _name;
    }

    /**
     *  unset primary name
     */
    function unsetName(address _owner) external onlyController returns (bool) {
        delete primaryName[_owner];
        return true;
    }

    /**
     *   get primary name
     */
    function getName(address _owner) external view returns (string memory) {
        bytes32 label = keccak256(bytes(primaryName[_owner]));
        require(
            expiries[uint256(label)] > block.timestamp,
            "ONS: NAME_EXPIRIES"
        );
        require(
            _isApprovedOrOwner(_owner, uint256(label)),
            "ONS: THIS_ADDRESS_IS_NOT_OWNER_ANYMORE"
        );
        return primaryName[_owner];
    }

    /**
     *   get primary name
     */
    function getNamebyID(uint256 _id) external view returns (string memory) {
        return doamins[_id];
    }

    /**
     *   get address by name
     */
    function getAddress(string memory _name) external view returns (address) {
        bytes32 label = keccak256(bytes(_name));
        return ownerOf(uint256(label));
    }

    /**
     *   get TokenURI
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        string memory currentBaseURI = baseURI;
        return
            bytes(currentBaseURI).length > 0
                ? string(abi.encodePacked(currentBaseURI, toString(tokenId)))
                : "";
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}
