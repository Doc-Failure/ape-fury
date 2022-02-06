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

  }

  // index of created contracts
  mapping(string => tokenLaunchCampaignStruct) public tokenLaunchCampaign;
  mapping(address => string[]) listOfTokenLaunchCampaignsPerUser;

  function getListOfTokenLaunchCampaignsPerUser() public view returns ( string[] memory){
    return listOfTokenLaunchCampaignsPerUser[msg.sender];
  }
  

  function setUpTokenLaunchCampaign(address _tokenAddr, uint128 _percentageEarlyUsersPool, uint128 _percentageLiquidityPool, uint128 _daysBeforeExpiring, string memory _tokenLaunchName ) public {
    require(_percentageEarlyUsersPool>0 && _percentageEarlyUsersPool<100);
    require(_percentageLiquidityPool>0 && _percentageLiquidityPool<100);
    //require(_daysBeforeExpiring>0 && _percentageLiquidityPool<180);
    require(tokenLaunchCampaign[_tokenLaunchName]._campaignOwner==0x0000000000000000000000000000000000000000 || msg.sender==tokenLaunchCampaign[_tokenLaunchName]._campaignOwner);
    uint256 totalSupply = ERC20Token(_tokenAddr).totalSupply();

    listOfTokenLaunchCampaignsPerUser[msg.sender].push(_tokenLaunchName);


    string memory tokenName= string(abi.encodePacked("tl",_tokenLaunchName));
    ERC20MintableBurnableToken liquidityToken = new ERC20MintableBurnableToken(tokenName, tokenName, address(this));

    tokenLaunchCampaignStruct memory campaignStruct;
    campaignStruct._tokenAddr=_tokenAddr;
    campaignStruct._quantityEarlyUsersPool=totalSupply*_percentageEarlyUsersPool/100;
    campaignStruct._quantityLiquidityPool=totalSupply*_percentageLiquidityPool/100;
    campaignStruct._expiringDay=block.timestamp+(_daysBeforeExpiring*86400);
    campaignStruct._campaignOwner=msg.sender;
    campaignStruct._temporaryLiquidityToken=address(liquidityToken);

    tokenLaunchCampaign[_tokenLaunchName] = campaignStruct;

    ERC20Token token = ERC20Token(tokenLaunchCampaign[_tokenLaunchName]._tokenAddr);
    token.transferFrom(msg.sender, address(this),  (tokenLaunchCampaign[_tokenLaunchName]._quantityEarlyUsersPool+tokenLaunchCampaign[_tokenLaunchName]._quantityLiquidityPool));
  }


  function fundTokenLaunchCampaign(string memory _tokenLaunchName, uint256 quantity ) external {
    require(tokenLaunchCampaign[_tokenLaunchName]._campaignOwner!=0x0000000000000000000000000000000000000000, "LaunchCampaign has not been approved yet");
    
    //Wrapped Near Fungible Token
    ERC20Token token = ERC20Token(0x4861825E75ab14553E5aF711EbbE6873d369d146);
    token.transferFrom(msg.sender, address(this),  quantity * 10 ** 18);

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

}


