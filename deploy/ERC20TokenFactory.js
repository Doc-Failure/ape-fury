module.exports = async function ({ ethers, deployments, getNamedAccounts }) {
  const { deploy } = deployments

  const { deployer, dev } = await getNamedAccounts()

  
  const { address } = await deploy("ERC20TokenFactory", {
    from: deployer,
    log: true,
    deterministicDeployment: false
  })

  if (address) {
    // Transfer Sushi Ownership to Chef
    console.log("ERC20TokenFactory deployed at address: "+address)
  }

}

module.exports.tags = ["ERC20TokenFactory"]
