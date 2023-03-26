const { ethers } = require("hardhat");
const { expect } = require("chai");

const primaryAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
const secondaryAddress = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";
const Token = {
  name: "SEWY",
  asset: "https://www.sewy.com/",
  category: "Bored APE",
  type: "ART",
  owner: primaryAddress,
};

const Token2 = {
  name: "SUIII",
  asset: "https://www.suii.com/",
  category: "Bored APE",
  type: "ART",
  owner: secondaryAddress,
};

describe("NFT Contract", () => {
  let nft, nftContract;

  before(async () => {
    nftContract = await ethers.getContractFactory("NFT");
    nft = await nftContract.deploy();
  });

  it("should mint a nft", async () => {
    await nft._mint(
      Token.name,
      Token.asset,
      Token.category,
      Token.type,
      Token.owner
    );
    const token = await nft._ownerOf(1);
    const owner = token._owner;
    expect(owner).to.equal(Token.owner);
  });

  it("should return the balance of account", async () => {
    const balance = await nft._balanceOf(Token.owner);
    expect(balance).to.equal(1);
  });

  it("should return the owner of nft", async () => {
    const token = await nft._ownerOf(1);
    const owner = token._owner;
    expect(owner).to.equal(Token.owner);
  });

  it("should transfer token from one address to another", async () => {
    const token = await nft._ownerOf(1);
    const oldOwner = token._owner;
    await nft._transferFrom(oldOwner, secondaryAddress, 1);
    const newToken = await nft._ownerOf(1);
    const newOwner = newToken._owner;
    expect(newOwner).to.equal(secondaryAddress);
  });

  it("should check if the nft already exists", async () => {
    const isExist = await nft._isExists(Token.name, Token.asset);
    expect(isExist).to.be.false;
  });

  it("should return the contract address", async () => {
    const address = await nft._getContractAddress();
    expect(address).to.equal(nft.address);
  });

  it("should return list of nft minted by user", async () => {
    const tokens = await nft._getTokens(secondaryAddress);
    expect(tokens[0]._owner).to.equal(secondaryAddress);
  });
});

describe("Marketplace Contract", () => {
  let nft, nftContract, marketContract, market;

  before(async () => {
    nftContract = await ethers.getContractFactory("NFT");
    nft = await nftContract.deploy();
    marketContract = await ethers.getContractFactory("Market");
    market = await marketContract.deploy(nft.address);
    await nft._mint(
      Token.name,
      Token.asset,
      Token.category,
      Token.type,
      Token.owner
    );
  });

  it("should add nft to the market listing", async () => {
    await market._createListing(
      1,
      ethers.utils.parseEther("5"),
      primaryAddress,
      {
        gasLimit: 5000000,
      }
    );
    const listing = await market._getListings();
    expect(listing[0]._token._owner).to.equal(Token.owner);
  });

  it("should get all the market listing", async () => {
    const listing = await market._getListings();
    expect(listing[0]._token._owner).to.equal(Token.owner);
  });

  it("should buy nft from the owner", async () => {
    await market._buyToken(1, secondaryAddress, {
      value: ethers.utils.parseEther("5"),
      gasLimit: 5000000,
    });
    const token = await nft._ownerOf(1);
    const owner = token._owner;
    expect(owner).to.equal(secondaryAddress);
  });

  it("should remove nft from the market listing", async () => {
    await market._createListing(
      1,
      ethers.utils.parseEther("5"),
      secondaryAddress,
      {
        gasLimit: 5000000,
      }
    );
    await market._cancelListing(1, secondaryAddress, {
      gasLimit: 5000000,
    });
    const listing = await market._getListings();
    expect(listing[0]._active).to.be.false;
  });

  it("should edit listing", async () => {
    await market._createListing(
      1,
      ethers.utils.parseEther("5"),
      secondaryAddress,
      {
        gasLimit: 5000000,
      }
    );
    await market._editListing(
      1,
      1,
      secondaryAddress,
      ethers.utils.parseEther("10"),
      false,
      {
        gasLimit: 5000000,
      }
    );
    const listing2 = await market._getListings();
  });
});
