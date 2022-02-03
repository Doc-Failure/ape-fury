// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

contract ERC20MintableBurnableToken is ERC20, ERC20Burnable {
    address owner;

    constructor (string memory name, string memory symbol, address _owner) public ERC20(name, symbol) {
        // Mint 100 tokens to msg.sender
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        owner=_owner;
    }

    function mint(address receiver, uint256 quantity) public{
        require(msg.sender==owner);
        _mint(receiver, quantity * 10 ** uint(decimals()));
    }
}