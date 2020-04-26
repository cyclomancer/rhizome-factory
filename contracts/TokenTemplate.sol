pragma solidity ^0.6.4;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";

/**
 * @title TokenTemplate
 * @dev Very simple ERC20 Token that can be minted.
 * It is meant to be used in all crowdsale contracts.
 */
contract TokenTemplate is ERC20Detailed, ERC20Mintable {
    event Debug(string _message);

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 totalSupply,
        address owner
    ) ERC20Detailed(name, symbol, decimals) ERC20Mintable() public {
        require(owner != address(0), "Owner must be defined");
        _logoURL = logoURL;
        _addMinter(owner);
        if (totalSupply > 0) {
            _mint(owner, totalSupply);
            _removeMinter(owner);
        }
    }

    /**
     * override of erc20 transfer
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount); //call to erc20 standard transfer
        return true;
    }
}