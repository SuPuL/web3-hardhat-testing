import { expect } from "chai";
import hre from "hardhat";
import { Contract } from "@ethersproject/contracts";

describe("NFT Contract", () => {
  let nft: Contract;
  let nftFactory: Contract;
  let nftRepository: Contract;

  beforeEach(async () => {
    const NFTRepository = await hre.ethers.getContractFactory("NFTRepository");
    nftRepository = await NFTRepository.deploy();
    await nftRepository.deployed();

    // deploy traits library
    const Traits = await hre.ethers.getContractFactory("Traits");
    const traits = await Traits.deploy();
    await traits.deployed();

    const NFTDescriptor = await hre.ethers.getContractFactory("NFTDescriptor", {
      libraries: { Traits: traits.address },
    });
    const nftDescriptor = await NFTDescriptor.deploy(nftRepository.address);
    await nftDescriptor.deployed();

    const NFT = await hre.ethers.getContractFactory("NFT");
    nft = await NFT.deploy(nftRepository.address, nftDescriptor.address);
    await nft.deployed();

    await nftRepository.grantRole(
      hre.ethers.utils.id("FACTORY_PRODUCER_ROLE"),
      nft.address
    );

    const NFTFactory = await hre.ethers.getContractFactory("MockNFTFactory");
    nftFactory = await NFTFactory.deploy();
    await nftFactory.deployed();
  });

  it("works", async () => {
    const [owner] = await hre.ethers.getSigners();

    await nftRepository.addEdition({
      seriesId: 1,
      editionId: 1,
      seriesName: hre.ethers.utils.formatBytes32String("Generation 1"),
      editionName: hre.ethers.utils.formatBytes32String("Edition 1"),
      allowedTypes: [
        {
          group: hre.ethers.utils.formatBytes32String("Monster"),
          name: hre.ethers.utils.formatBytes32String("Unidonkey"),
          description: hre.ethers.utils.formatBytes32String("Test Description"),
          traitTypes: [
            {
              traitType: hre.ethers.utils.formatBytes32String("Color"),
              displayType: hre.ethers.utils.formatBytes32String(""),
              traits: [
                { name: hre.ethers.utils.formatBytes32String("Red") },
                { name: hre.ethers.utils.formatBytes32String("Blue") },
                { name: hre.ethers.utils.formatBytes32String("Green") },
              ],
            },
            {
              traitType: hre.ethers.utils.formatBytes32String("Horn"),
              displayType: hre.ethers.utils.formatBytes32String(""),
              traits: [
                { name: hre.ethers.utils.formatBytes32String("Golden Horn") },
                { name: hre.ethers.utils.formatBytes32String("Silver Edge") },
                { name: hre.ethers.utils.formatBytes32String("Spiral Horn") },
              ],
            },
          ],
        },
      ],
    });

    await nftRepository.setFactory(1, 1, nftFactory.address);

    await nft.airdrop(
      owner.address,
      1,
      1,
      hre.ethers.utils.formatBytes32String("Unidonkey"),
      [
        {
          traitType: hre.ethers.utils.formatBytes32String("Color"),
          traitName: hre.ethers.utils.formatBytes32String("Red"),
        },
        {
          traitType: hre.ethers.utils.formatBytes32String("Horn"),
          traitName: hre.ethers.utils.formatBytes32String("Golden Horn"),
        },
      ]
    );

    const tokenURI = await nft.tokenURI(2);
    console.log(`token Uri ==================`, tokenURI);
    // // decode base64 string
    // const decoded = Buffer.from(tokenURI.split(",")[1], "base64").toString();
    // console.log(decoded);
  });
});
