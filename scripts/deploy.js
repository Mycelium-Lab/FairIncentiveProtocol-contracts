// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const signer = await hre.ethers.getSigner()
  const FairProtocolManager = await ethers.getContractFactory('FairProtocolERC20Manager')
  fpmanager = await FairProtocolManager.deploy(signer.address)
  await fpmanager.deployed()

  console.log(`FPManager deployed to address: ${fpmanager.address}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
