pragma solidity ^0.6.4;

import "./TokenFactory.sol";
import "./TokenTemplate.sol";

import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";

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
    using SafeMath for uint256;

    address public creator;
    string public name;

    TokenTemplate public RhizomeRewards;

    mapping(address => uint) roles;
    mapping(address => uint) allocations;

    uint256 public constant ELIGIBLE_UNIT = 10 ** 9;
    mapping(address => uint256) internal _stake;
    mapping(address => uint256) internal _stakeRemainder;
    uint256 internal _stakeTotal;
    uint256 internal _rewardTotal;
    uint256 internal _rewardRemainder;
    mapping(address => int256) _rewardOffset;

    uint internal constant ROLE_FACILITATOR = 40;
    uint internal constant ROLE_RECIPIENT = 30;
    uint internal constant ROLE_PROJECT = 20;
    uint internal constant ROLE_NONE = 0;

    string internal constant INSUFFICIENT_PRIVILEGES = "Action requires admin privileges";
    string internal constant INVALID_TARGET = "Amount must be nonzero";
    string internal constant INSUFFICIENT_FUNDS = "Allocation exceeds available funds";

    constructor(
        string memory _name,
        address _creator,
    ) public {
        bytes memory testName = bytes(_name);
        require(testName.length > 0, "DAO Name cannot be empty");

        name = _name;
        creator = _creator;

        _stakeTotal = 0;
        _rewardTotal = 0;
        _rewardRemainder = 0;

        roles[creator] = ROLE_FACILITATOR;

        RhizomeRewards = new TokenTemplate('Rhizome', 'RHR', 18, 0, msg.sender);
    }

    function addProject(address _project) public {
        require(roles[msg.sender] == ROLE_FACILITATOR, INSUFFICIENT_PRIVILEGES);
        roles[_project] = ROLE_PROJECT;
    }

    functional allocate(address _project, uint256 amount) public {
        require(amount <= address(this).balance, INSUFFICIENT_FUNDS);
        
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

    function deposit(address staker, uint256 tokens) public returns (bool success) {
        uint256 _tokensToAdd = tokens.add(_stakeRemainder[staker]);

        uint256 _eligibleUnitsToAdd = _tokensToAdd.div(ELIGIBLE_UNIT);

        // update the new remainder for this address
        _stakeRemainder[msg.sender] = _tokensToAdd.mod(ELIGIBLE_UNIT);

        // set the current stake for this address
        _stake[staker] = _stake[staker].add(_eligibleUnitsToAdd);

        // update total eligible stake units
        _stakeTotal = _stakeTotal.add(_eligibleUnitsToAdd);

        // update reward offset
        _rewardOffset[staker] += (int256)(_rewardTotal * _eligibleUnitsToAdd);

        return true;
    }

    /// @notice Distribute tokens pro rata to all stakers.
    function distribute(address project) internal returns (bool success) {
        uint256 rewards = allocations[project];
        /////
        // add past distribution remainder
        uint256 _amountToDistribute = rewards.add(_rewardRemainder);

        if (_stakeTotal == 0) {
            _rewardRemainder = _amountToDistribute;
        } else {
            // determine rewards per eligible stake
            uint256 _ratio = _amountToDistribute.div(_stakeTotal);

            // carry on remainder
            _rewardRemainder = _amountToDistribute.mod(_stakeTotal);

            // increase total rewards per stake unit
            _rewardTotal = _rewardTotal.add(_ratio);
        }
        return true;
    }

    /// @notice Withdraw accumulated reward for the staker address.
    function withdrawReward() public returns (uint256 tokens) {
        uint256 _reward = getReward(msg.sender);

        // refresh reward offset (so a new call to getReward returns 0)
        _rewardOffset[staker] = (int256)(_rewardTotal.mul(_stake[staker]));

        RhizomeRewards.mint(msg.sender, _reward);
    }

    /// @notice Withdraw stake for the staker address
    function withdrawStake(address staker, uint256 tokens) public onlyOwner returns (bool) {
        uint256 _currentStake = getStake(staker);

        require(tokens <= _currentStake);

        // update stake and remainder for this address
        uint256 _newStake = _currentStake.sub(tokens);

        _stakeRemainder[staker] = _newStake.mod(ELIGIBLE_UNIT);

        uint256 _eligibleUnitsDelta = _stake[staker].sub(_newStake.div(ELIGIBLE_UNIT));

        _stake[staker] = _stake[staker].sub(_eligibleUnitsDelta);

        // update total stake
        _stakeTotal = _stakeTotal.sub(_eligibleUnitsDelta);

        // update reward offset
        _rewardOffset[staker] -= (int256)(_rewardTotal.mul(_eligibleUnitsDelta));

        return true;
    }

    /// @notice Withdraw stake for the staker address
    function withdrawAllStake(address staker) public onlyOwner returns (bool) {
        uint256 _currentStake = getStake(staker);
        return withdrawStake(staker, _currentStake);
    }

    ///
    /// READ ONLY
    ///

    /// @notice Read total stake.
    function getStakeTotal() public view returns (uint256) {
        return _stakeTotal.mul(ELIGIBLE_UNIT);
    }

    /// @notice Read current stake for address.
    function getStake(address staker) public view returns (uint256 tokens) {
        tokens = (_stake[staker].mul(ELIGIBLE_UNIT)).add(_stakeRemainder[staker]);

        return tokens;
    }

    /// @notice Read current accumulated reward for address.
    function getReward(address staker) public view returns (uint256 tokens) {
        int256 _tokens = ((int256)(_stake[staker].mul(_rewardTotal)) - _rewardOffset[staker]);

        tokens = (uint256)(_tokens);

        return tokens;
    }
}