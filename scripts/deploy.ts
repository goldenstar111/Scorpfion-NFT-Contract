// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  let [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
  // We get the contract to deploy
  // const provider = new ethers.providers.Web3Provider();
  const USDT = await ethers.getContractFactory("USDT");
  const usdt = await USDT.deploy();
  await usdt.deployed();
  console.log("USDT deployed to:", usdt.address);

  // await usdt.transfer(
  //   "0xD15388a7F80109e58685C0474365b302A2E34d5E",
  //   ethers.utils.parseEther("1000")
  // );
  // console.log(
  //   "USDT Addr1:",
  //   ethers.utils.formatEther(await usdt.balanceOf(await addr1.getAddress()))
  // );
  // await usdt.transfer(
  //   await addr2.getAddress(),
  //   ethers.utils.parseEther("1000")
  // );
  // console.log(
  //   "USDT Addr2:",
  //   ethers.utils.formatEther(await usdt.balanceOf(await addr2.getAddress()))
  // );

  const MSPC = await ethers.getContractFactory("MSPC");
  const mspc = await MSPC.deploy();
  await mspc.deployed();
  console.log("MSPC deployed to:", mspc.address);

  // await mspc.transfer(
  //   "0xD15388a7F80109e58685C0474365b302A2E34d5E",
  //   ethers.utils.parseEther("1000")
  // );

  // console.log(
  //   "MSPC Addr1:",
  //   ethers.utils.formatEther(await mspc.balanceOf(await addr1.getAddress()))
  // );

  // await mspc.transfer(
  //   await addr2.getAddress(),
  //   ethers.utils.parseEther("1000")
  // );

  // console.log(
  //   "MSPC Addr2:",
  //   ethers.utils.formatEther(await mspc.balanceOf(await addr2.getAddress()))
  // );

  const Marketplace = await ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy(usdt.address, mspc.address);
  await marketplace.deployed();
  console.log("Marketplace deployed to:", marketplace.address);

  const Mr = await ethers.getContractFactory("Mr");
  const mr = await Mr.deploy(marketplace.address);
  await mr.deployed();
  console.log("NFT Mr deployed to:", mr.address);

  const Ms = await ethers.getContractFactory("Ms");
  const ms = await Ms.deploy(marketplace.address);
  await ms.deployed();
  console.log("NFT Ms deployed to:", ms.address);

  // await nft.mintToken();

  // console.log(`NFT with id: 1 is created`);

  // await marketplace.mintMarketItem(
  //   nft.address,
  //   1,
  //   ethers.utils.parseEther("30"),
  //   ethers.utils.parseEther("50"),
  //   {
  //     gasLimit: 100000,
  //   }
  // );
  // console.log("Market item with id: 1 is created");

  // await nft.mintToken();
  // console.log(`Market item with id: 2 is created`);
  // await marketplace.mintMarketItem(
  //   nft.address,
  //   1,
  //   ethers.utils.parseEther("30"),
  //   ethers.utils.parseEther("50")
  // );

  // console.log(`Market item with id: 2 is created`);

  // for (let i = 1; i < 20; i++) {
  //   await nft.mintToken();
  //   console.log(`NFT with id: ${i} is created`);

  //   await marketplace.mintMarketItem(
  //     nft.address,
  //     i,
  //     ethers.utils.parseEther("30"),
  //     ethers.utils.parseEther("50")
  //   );
  //   console.log(`Market item with id: ${i} is created`);
  // }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
