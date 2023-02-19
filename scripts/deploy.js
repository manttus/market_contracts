const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  const NFT = await hre.ethers.getContractFactory("NFT");
  const nft = await NFT.deploy();
  // const Marketplace = await hre.ethers.getContractFactory("Market");
  // const marketplace = await Marketplace.deploy();
  console.log("NFT address:", nft.address);
  // console.log("Marketplace address:", marketplace.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
