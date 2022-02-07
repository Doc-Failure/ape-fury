// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;
import "./ERC20Token.sol";

contract ERC20TokenFactory {

  struct tokenStruct{ 
    string _symbol;
    string _name;
    address _address;
  }
  // index of created contracts
  mapping(address => address) public lastDeployedContract;

  tokenStruct[] public contracts;

  function getContracts() public view returns(tokenStruct[] memory){
    return contracts;
  }

  function getLastDeployedContract() public view returns(address){
    return lastDeployedContract[msg.sender];
  }

  // deploy a new contract
  function deployNewToken(string memory name, string memory symbol, uint initialSupply) public{
    ERC20Token token = new ERC20Token(name,symbol,initialSupply);
    address contractAddress = address(token);
    tokenStruct memory tokenToInsert;
    tokenToInsert._name = name;
    tokenToInsert._symbol = symbol;
    tokenToInsert._address = contractAddress;
    
    contracts.push(tokenToInsert);
    lastDeployedContract[msg.sender]=contractAddress;

    token.transfer(msg.sender, token.totalSupply());
  }

  function resetButton() public{
    //require(msg.sender==0xb82F1f95C89cb666f53e6461171311d6aF9F63Ae);
    delete contracts;
  }
}