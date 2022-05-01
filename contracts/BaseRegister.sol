pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract BaseRegister is Ownable, IERC721 {
    uint256 public constant GRACE_PERIOD = 90 days;

    event ControllerAdded(address indexed controller);
    event ControllerRemoved(address indexed controller);
    event NameMigrated(
        uint256 indexed id,
        address indexed owner,
        uint256 expires
    );
    event NameRegistered(
        uint256 indexed id,
        address indexed owner,
        uint256 expires
    );
    event NameRenewed(uint256 indexed id, uint256 expires);
    event ChangeBaseURI(string _baseURI);

    string public baseURI;

    bytes32 public baseNode;

    mapping(address => bool) public controllers;

    function addController(address controller) external virtual;

    function removeController(address controller) external virtual;

    function nameExpires(uint256 id) external view virtual returns (uint256);

    function available(uint256 id) public view virtual returns (bool);

    function register(
        uint256 id,
        string memory name,
        address owner,
        uint256 duration
    ) external virtual returns (uint256);

    function renew(uint256 id, uint256 duration)
        external
        virtual
        returns (uint256);

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
