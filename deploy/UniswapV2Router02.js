const { WETH9 } = require("@sushiswap/sdk");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  const chainId = await getChainId();
  let wethAddress;

  console.log("--------- chainId: "+chainId);
  if (chainId === "31337" || chainId === "365") {
    console.log("OKOKOKOKOKOK????");


    const {address} = await deploy("WETH9Mock", {
      from: deployer,
      log: true,
      deterministicDeployment: false
    })
    wethAddress=address;

   /*  wethAddress = (await deployments.get("WETH9Mock")).address; */
    console.log("wethAddress: "+wethAddress);
  } else if (chainId in WETH9) {
    wethAddress = WETH9[chainId].address;
  } else {
    throw Error("No WETH!");
  }

  console.log("--------- wethAddress: "+wethAddress);

  const factoryAddress = (await deployments.get("UniswapV2Factory")).address;

  await deploy("UniswapV2Router02", {
    from: deployer,
    args: [factoryAddress, wethAddress],
    log: true,
    deterministicDeployment: false,
  });
};

module.exports.tags = ["UniswapV2Router02", "AMM"];
module.exports.dependencies = ["UniswapV2Factory", "Mocks"];
