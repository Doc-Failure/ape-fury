// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
import "./ERC20Token.sol";

contract ERC20TokenFactory {

  // index of created contracts
  mapping(address => address) public lastDeployedContract;

  address[] public contracts;

  function getContracts() public view returns(address[] memory){
    return contracts;
  }

  function getLastDeployedContract() public view returns(address){
    return lastDeployedContract[msg.sender];
  }

  // deploy a new contract
  function deployNewToken(string memory name, string memory symbol, uint initialSupply) public{
    ERC20Token token = new ERC20Token(name,symbol,initialSupply);
    address contractAddress = address(token);
    contracts.push(contractAddress);
    lastDeployedContract[msg.sender]=contractAddress;

    token.transfer(msg.sender, token.totalSupply());
  }
}