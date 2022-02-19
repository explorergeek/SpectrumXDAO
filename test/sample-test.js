const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");
    await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});

// Will mint NFT locally to make sure everything is working

const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory('BohoNFT');
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();
  console.log("Contract deployed to:", nftContract.address);
  
  // Call the function.
  let txn = await nftContract.makeABohoNFT()
  // Wait for it to be mined.
  await txn.wait()

  // Mint another NFT for fun.
  txn = await nftContract.makeABohoNFT()
  // Wait for it to be mined.
  await txn.wait()
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
