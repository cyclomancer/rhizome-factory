pragma solidity ^0.6.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title TokenTemplate
 * @dev Very simple ERC20 Token that can be minted.
 * It is meant to be used in all crowdsale contracts.
 */
contract TokenTemplate is ERC20 {
    event Debug(string _message);
    address public _owner;
    constructor(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        address owner
    ) ERC20(name, symbol) public {
        require(owner != address(0), "Owner must be defined");
        if (totalSupply > 0) {
            _mint(owner, totalSupply);
        }
        _owner = owner;
    }

    /**
     * override of erc20 transfer
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount); //call to erc20 standard transfer
        return true;
    }
    
    function mint(address recipient, uint256 amount)
    public {
        require(msg.sender == _owner, "Access denied");
        _mint(recipient, amount);
    }
}