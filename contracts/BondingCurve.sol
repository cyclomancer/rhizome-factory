pragma solidity ^0.6.4;

import "./DAO.sol";

contract BondingCurve is DSMath {
    address payable public beneficiary;
    CcDAO public rhizome;
    uint public currentSupply;
    uint public totalContributed;
    uint public totalLocked;
    mapping (address => uint) public ledger;
    mapping(address => uint) public locked;
    mapping (address => uint) public contributions;
    mapping (address => uint) public asks;

    uint public exponent;
    uint public coefficient;
    uint public reserveRatio;
    
    uint public constant precision = 1000000000000000000;

    string internal constant INSUFFICIENT_ETH = 'Insufficient Ether';
    string internal constant INSUFFICIENT_TOKENS = 'Request exceeds token balance';
    string internal constant INVALID_ADDRESS = 'Wallet does not exist';
    string internal constant ZERO_AMOUNT = "Amount must be nonzero";
    string internal constant TOKENS_LOCKED = "Vesting period for this stake has not elapsed";

    constructor(
        address _DAO
    )
    public {
        beneficiary = payable(_DAO);
        rhizome = CcDAO(_DAO);
        exponent = 2;
        coefficient = 10000000000;
        reserveRatio = wdiv(4, 5);
        currentSupply = 1;
    }
    
    function buy(uint amount)
    external payable {
        uint price = calcMintPrice(amount);
        require(msg.value >= price, INSUFFICIENT_ETH);
        uint reserveValue = wmul(msg.value, reserveRatio);
        uint contributionValue = sub(msg.value, reserveValue);
        uint refund = msg.value - reserveValue - contributionValue;
        if (refund > 0) {
            msg.sender.transfer(refund);
        }
        ledger[msg.sender] = add(ledger[msg.sender], amount);
        currentSupply = add(currentSupply, amount);
        contribute(contributionValue, msg.sender);
    }

    function sell(uint amount)
    external {
        require(amount <= ledger[msg.sender], INSUFFICIENT_TOKENS);
        uint exitValue = calcBurnReward(amount);
        msg.sender.transfer(exitValue);
        ledger[msg.sender] = sub(ledger[msg.sender], amount);
        currentSupply = sub(currentSupply, amount);
    }

    // function lovequit()
    // external {
    //     require(ledger[msg.sender] > 0, INVALID_ADDRESS);
    //     uint holdings = ledger[msg.sender];
    //     uint exitValue = calcBurnReward(holdings);
    //     currentSupply = sub(currentSupply, holdings);
    //     contribute(exitValue, msg.sender);
    //     ledger[msg.sender] = 0;
    // }

    function contribute(uint amount, address sender)
    internal {
        beneficiary.transfer(amount);
        contributions[sender] = add(contributions[sender], amount);
        totalContributed = add(totalContributed, amount);
    }
    
    function setBuyPrice(uint amount)
    public {
        uint price = calcMintPrice(amount);
        asks[msg.sender] = price;
    }
    
    function getPrice()
    public view returns (uint) {
        return asks[msg.sender];
    }
    
    function setSellPrice(uint amount)
    public {
        uint price = calcBurnReward(amount);
        asks[msg.sender] = price;
    }

    function integrate(uint limitA, uint limitB, uint multiplier)
    internal returns (uint) {
        uint raiseExp = exponent + 1;
        uint _coefficient = wmul(coefficient, multiplier);
        uint upper = wdiv((limitB ** raiseExp), raiseExp);
        uint lower = wdiv((limitA ** raiseExp), raiseExp);
        return wmul(_coefficient, (sub(upper, lower)));
    }
    
    function calcMintPrice(uint amount)
    internal returns (uint) {
        uint newSupply = add(currentSupply, amount);
        uint result = integrate(currentSupply, newSupply, precision);
        return result;
    }

    function calcBurnReward(uint amount)
    internal returns (uint) {
        uint newSupply = sub(currentSupply, amount);
        uint result = integrate(newSupply, currentSupply, reserveRatio);
        return result;
    }

    function lockTokens(uint amount)
    external {
        require(amount > 0, ZERO_AMOUNT);
        require(amount <= ledger[msg.sender], INSUFFICIENT_TOKENS);
        uint newLockBalance = add(locked[msg.sender], amount);
        uint newLedgerBalance = sub(ledger[msg.sender], amount);
        locked[msg.sender] = newLockBalance;
        ledger[msg.sender] = newLedgerBalance;
        totalLocked += amount;
        bool success = rhizome.deposit(msg.sender, amount);
        if (!success) {
            revert("DAO contract rejected deposit");
        }
    }

    function unlockTokens(uint amount)
    external {
        require(amount > 0, ZERO_AMOUNT);
        require(amount <= locked[msg.sender], INSUFFICIENT_TOKENS);
        uint newLockBalance = sub(locked[msg.sender], amount);
        uint newLedgerBalance = add(ledger[msg.sender], amount);
        locked[msg.sender] = newLockBalance;
        ledger[msg.sender] = newLedgerBalance;
        totalLocked -= amount;
        bool success = rhizome.withdrawStake(msg.sender, amount);
        if (!success) {
            revert("DAO contract rejected withdrawal");
        }
    }
}