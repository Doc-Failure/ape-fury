module.exports = async function ({ ethers, deployments, getNamedAccounts }) {
  const { deploy } = deployments

  const { deployer, dev } = await getNamedAccounts()

  
  let { address } = await deploy("ERC20TokenFactory", {
    from: deployer,
    log: true,
    deterministicDeployment: false
  })

  if (address) {
    // Transfer Sushi Ownership to Chef
    console.log("ERC20TokenFactory deployed at address: "+address)
  }

  await deploy("ERC20TokenLauncher", {
    from: deployer,
    log: true,
    deterministicDeployment: false
  })

  const ERC20TokenLauncher = await ethers.getContract("ERC20TokenLauncher")
  if (ERC20TokenLauncher) {
    // Transfer Sushi Ownership to Chef
    console.log("ERC20TokenLauncher deployed at address: "+ERC20TokenLauncher)
  }

}

module.exports.tags = ["ERC20TokenFactory", "ERC20TokenLauncher"]
