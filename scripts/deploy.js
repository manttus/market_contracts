const hre = require("hardhat");
const { artifacts } = require("hardhat");
const path = require("path");
const fs = require("fs");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  const NFT = await hre.ethers.getContractFactory("NFT");
  const nft = await NFT.deploy();
  const Marketplace = await hre.ethers.getContractFactory("Market");
  const marketplace = await Marketplace.deploy(nft.address);
  console.log("NFT address:", nft.address);
  console.log("Marketplace address:", marketplace.address);
  saveJSONFile("NFT", nft);
  saveJSONFile("Market", marketplace);
}

const saveJSONFile = (contract, data) => {
  const contracts_data = path.join(__dirname, "..", "contract_data");

  if (!fs.existsSync(contracts_data)) {
    fs.mkdirSync("contract_data");
  }

  fs.writeFileSync(
    contracts_data + `\\${contract}-address` + ".json",
    JSON.stringify({ address: data.address }, undefined, 2)
  );

  const readArtifact = artifacts.readArtifactSync(contract);

  fs.writeFileSync(
    contracts_data + `\\${contract}` + ".json",
    JSON.stringify(readArtifact, null, 2)
  );
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
