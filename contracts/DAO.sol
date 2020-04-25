pragma solidity ^0.6.4;

import "./TokenFactory.sol";
import "./TokenTemplate.sol";

/**
 * @dev Implementation of a DAO (Decentralized Autonomous Organization) for the CommonsHood app.
 *
 * This implementation consists in an organization that have an owner and various members with
 * various roles. The organization is capable of issuing tokens (ERC20 compliant) or Crowdsales.
 * Tokens can be transfered to others accounts or others DAOs. Only members with a role grater
 * than or equal to ROLE_ADMIN can issue new tokens and crowdsales.
 *
 * Users can join the DAO with the role ROLE_MEMBER. They can be promoted to higher roles only by a
 * ROLE_ADMIN or a ROLE_OWNER. All writing operations can be performed only by users with ROLE_ADMIN
 * or higher.
 */
contract CcDAO {
    address public creator;
    string public name;
    uint public totalAvailable;

    TokenFactory public tokenFactory;

    string internal constant INSUFFICIENT_PRIVILEGES = "Action requires admin privileges";
    string internal constant INVALID_TARGET;

    mapping(address => uint) roles;
    mapping(address => uint) allocations;    

    constructor(
        TokenFactory _tokenFactory,
        string memory _name,
        address _creator
    ) public {
        bytes memory testName = bytes(_name);

        require(testName.length > 0, "DAO Name cannot be empty");
        require(address(_tokenFactory) != address(0), "Must be a deployed TokenFactory");

        name = _name;
        creator = _creator;
        tokenFactory = _tokenFactory;

        roles[creator] = ROLE_OWNER;
    }

    function addProject(address _project) public {
        require(roles[msg.sender] == ROLE_FACILITATOR, INSUFFICIENT_PRIVILEGES);
        roles[_project] = ROLE_PROJECT;
    }

    /**
     * @dev kickMember allows a member to kick a lower-in-grade member.
     * @param _member the address of the member to kick.
     */
    function kickProject(address _project) public {
        require(roles[_project] > ROLE_NONE, "not a member, cannot kick");
        require(roles[_project]) < ROLE_RECIPIENT, 
        require(roles[msg.sender] > ROLE_PROJECT, INSUFFICIENT_PRIVILEGES);
        require()
        delete(roles[_member]);
    }

    /**
     * @dev transferToken performs a token transfer.
     * @param _symbol the symbol of the token to transfer.
     * @param _amount the amount to transfer.
     * @param _to the destination address.
     */
    function transferToken(string memory _symbol, uint256 _amount, address _to) public {
        require(roles[msg.sender] >= ROLE_ADMIN, "Only admins or more can transfer money outside the wallet");

        address tokenAddr = address(0);
        (tokenAddr, , , , , , ) = tokenFactory.getToken(_symbol);
        TokenTemplate token = TokenTemplate(tokenAddr);
        require(token.balanceOf(address(this)) >= _amount, "Must have the tokens in the DAO wallet");
        require(token.transfer(_to, _amount), "Must have transferred the tokens");
    }

        /**
     * @dev createToken creates a new TokenTemplate instance.
     * @param _name the name of the Token
     * @param _symbol the symbol of the Token.
     * @param _logoURL the URL of the image representing the logo of the Token.
     * @param _logoHash the Hash of the image pointed by _logoURL, to ensure it has not been altered.
     * @param _hardCap the total supply of the Token.
     * @param _contractHash the Hash of the PDF contract bound to this Token.
     */
    function createToken(
        string memory _name,
        string memory _symbol,
        string memory _logoURL,
        bytes32 _logoHash,
        uint256 _hardCap,
        bytes32 _contractHash
        ) public {
        require(roles[msg.sender] >= ROLE_ADMIN, "Only admins or higher roles can issue new tokens");
        tokenFactory.createToken(_name, _symbol, 0, _logoURL, _logoHash, _hardCap, _contractHash);
    }
}