// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;
import "./ERC20Token.sol";
import "./ERC20MintableBurnableToken.sol";

contract ERC20TokenLauncher {

  struct tokenLaunchCampaignStruct{ 
    address _tokenAddr;
    uint256 _quantityEarlyUsersPool;
    uint256 _quantityLiquidityPool;
    uint _expiringDay;
    address _campaignOwner;
    address _temporaryLiquidityToken;
    string _launchName;

  }

  // index of created contracts
  mapping(string => tokenLaunchCampaignStruct) public tokenLaunchCampaign;
  tokenLaunchCampaignStruct[] listOfTokenLaunchCampaigns;

  function getListOfTokenLaunchCampaigns() public view returns ( tokenLaunchCampaignStruct[] memory){
    return listOfTokenLaunchCampaigns;
  }

  function setUpTokenLaunchCampaign(address _tokenAddr, uint128 _percentageEarlyUsersPool, uint128 _percentageLiquidityPool, uint128 _daysBeforeExpiring, string memory _tokenLaunchName ) public {
    require(_percentageEarlyUsersPool>0 && _percentageEarlyUsersPool<100);
    require(_percentageLiquidityPool>0 && _percentageLiquidityPool<100);
    require(_daysBeforeExpiring>0 && _percentageLiquidityPool<180);
    require(tokenLaunchCampaign[_tokenLaunchName]._campaignOwner==0x0000000000000000000000000000000000000000 || msg.sender==tokenLaunchCampaign[_tokenLaunchName]._campaignOwner);
    ERC20 token = ERC20(_tokenAddr);
    uint256 totalSupply = token.totalSupply();



    string memory tokenName= string(abi.encodePacked("tl",_tokenLaunchName));
    ERC20MintableBurnableToken liquidityToken = new ERC20MintableBurnableToken(tokenName, tokenName, address(this));

    tokenLaunchCampaignStruct memory campaignStruct;
    campaignStruct._launchName=_tokenLaunchName;
    campaignStruct._tokenAddr=address(token);
    campaignStruct._quantityEarlyUsersPool=totalSupply*_percentageEarlyUsersPool/100;
    campaignStruct._quantityLiquidityPool=totalSupply*_percentageLiquidityPool/100;
    campaignStruct._expiringDay=block.timestamp+(_daysBeforeExpiring*86400);
    campaignStruct._campaignOwner=msg.sender;
    campaignStruct._temporaryLiquidityToken=address(liquidityToken);

    tokenLaunchCampaign[_tokenLaunchName] = campaignStruct;
    listOfTokenLaunchCampaigns.push(campaignStruct);

    token.transferFrom(msg.sender, address(this),  (tokenLaunchCampaign[_tokenLaunchName]._quantityEarlyUsersPool+tokenLaunchCampaign[_tokenLaunchName]._quantityLiquidityPool));
  }


  function fundTokenLaunchCampaign(string memory _tokenLaunchName, uint256 quantity ) external {
    require(tokenLaunchCampaign[_tokenLaunchName]._campaignOwner==0x0000000000000000000000000000000000000000, "LaunchCampaign has not been approved yet");
    
    //Wrapped Near Fungible Token
    ERC20 token = ERC20(0x4861825E75ab14553E5aF711EbbE6873d369d146);
    token.transferFrom(msg.sender, address(this),  quantity);

    ERC20MintableBurnableToken tl_token = ERC20MintableBurnableToken(tokenLaunchCampaign[_tokenLaunchName]._temporaryLiquidityToken);
    tl_token.mint(msg.sender, quantity);
  }


  function receivefundFromTokenLaunchCampaign(string memory _tokenLaunchName, uint256 quantity) external {
    require( block.timestamp > tokenLaunchCampaign[_tokenLaunchName]._expiringDay);
    //TODO - Sposto i token dal contratto al pool di liquidita' e invio gli lp_ERC20 al founder principale?
    //TOFO - Devo contare quanti Near sono stati messi in sto cazzo di contratto

    ERC20MintableBurnableToken tl_token = ERC20MintableBurnableToken(tokenLaunchCampaign[_tokenLaunchName]._temporaryLiquidityToken);

    uint256 quantityToMove = tokenLaunchCampaign[_tokenLaunchName]._quantityEarlyUsersPool*((quantity * 10 ** 18)/tl_token.totalSupply());
    tokenLaunchCampaign[_tokenLaunchName]._quantityEarlyUsersPool-=quantityToMove;

    ERC20Token token = ERC20Token(tokenLaunchCampaign[_tokenLaunchName]._tokenAddr);
    token.transfer(msg.sender, quantityToMove);

    tl_token.burnFrom(msg.sender, (quantity * 10 ** 18));
  }

  //only for test purpose
  function resetButton() public{
    delete listOfTokenLaunchCampaigns;
  }

}


