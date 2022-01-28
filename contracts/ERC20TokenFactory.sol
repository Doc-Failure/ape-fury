// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
import "./ERC20Token.sol";

contract ERC20TokenFactory {

  // index of created contracts
  address[] public contracts;

  function getContracts() public view returns(address[] memory){
    return contracts;
  }

  // deploy a new contract
  function deployNewToken(string memory name, string memory symbol, uint initialSupply) 
    public returns(address newContract){
      ERC20Token token = new ERC20Token(name,symbol,initialSupply);
      address contractAddress = address(token);
      contracts.push(contractAddress);

      token.transfer(msg.sender, token.totalSupply());
      
      return contractAddress;
    }
}