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


  const Marketplace = await ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy();
  await marketplace.deployed();
  console.log("Marketplace deployed to:", marketplace.address);

  const ScorpionNFT = await ethers.getContractFactory("ScorpionNFT");
  const Scorp = await ScorpionNFT.deploy();
  // const Scorp = await ScorpionNFT.deploy(marketplace.address);
  await Scorp.deployed();
  console.log("NFT Scorp deployed to:", Scorp.address);

  await Scorp._setbaseURI("https://ipfs.io/ipfs/QmR1bLXTtCRu14SRAXoLuHfdv6PyYm1pv6yLxLUSBfR7my/");
  await Scorp.setApprovalForAll(marketplace.address, true);
  // const owneraddr = await owner.getAddress();
  // await Scorp.setApprovalForAll(owneraddr, true);

  await marketplace.setScorp(Scorp.address);
  // await marketplace.initNFTLevels();

  // const Ms = await ethers.getContractFactory("Ms");
  // const ms = await Ms.deploy(marketplace.address);
  // await ms.deployed();
  // console.log("NFT Ms deployed to:", ms.address);

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
