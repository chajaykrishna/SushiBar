// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const SushiToken = await ethers.getContractFactory("Sushi");
  const sushiToken = await SushiToken.deploy();
  const SushiBar = await ethers.getContractFactory("SushiBar");
  const sushiBar = await SushiBar.deploy(sushiToken.address);

  //set the sushibar address in the sushi token contract
  const txn = await sushiToken.setSushibarAddress(sushiBar.address);
  await txn.wait();

  console.log("SushiBar Address: ", sushiBar.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
