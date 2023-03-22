import hre from "hardhat";
import { Contract } from "@ethersproject/contracts";

const baseExternalUrl = "https://base.foobar";
const imageBaseUrl = "https://image.foobar";
const assetBaseUrl = "https://asset.foobar";

describe("NFT Collection", () => {
  let nft: Contract;
  let nftSchema: Contract;

  beforeEach(async () => {
    // deploy traits library
    const Traits = await hre.ethers.getContractFactory("Traits");
    const traits = await Traits.deploy();
    await traits.deployed();
    // deploy schema library
    const Schema = await hre.ethers.getContractFactory("Schema");
    const schema = await Schema.deploy();
    await schema.deployed();
    // deploy json library
    const JSON = await hre.ethers.getContractFactory("JSON");
    const json = await JSON.deploy();
    await json.deployed();

    // deploy NftSchema
    const NFTSchema = await hre.ethers.getContractFactory("NFTSchema", {
      libraries: { Schema: schema.address },
    });
    nftSchema = await NFTSchema.deploy();
    await nftSchema.deployed();

    const NFTRepository = await hre.ethers.getContractFactory("NFTRepository", {
      libraries: { Traits: traits.address, Schema: schema.address },
    });
    const nftRepository = await NFTRepository.deploy(nftSchema.address);
    await nftRepository.deployed();

    const NFTTokenUriProvider = await hre.ethers.getContractFactory(
      "NFTTokenUriProvider",
      {
        libraries: { JSON: json.address },
      }
    );
    const nftTokenUriProvider = await NFTTokenUriProvider.deploy(
      baseExternalUrl,
      imageBaseUrl,
      assetBaseUrl
    );
    await nftTokenUriProvider.deployed();

    const NFT = await hre.ethers.getContractFactory("NFTCollection");
    nft = await NFT.deploy(
      "FOO",
      "BAR",
      nftRepository.address,
      nftTokenUriProvider.address
    );
    await nft.deployed();

    await nftRepository.grantRole(
      hre.ethers.utils.id("REPOSITORY_PRODUCER_ROLE"),
      nft.address
    );

    // const NFTFactory = await hre.ethers.getContractFactory("MockNFTFactory");
    // nftFactory = await NFTFactory.deploy();
    // await nftFactory.deployed();
  });

  it("works", async () => {
    const [owner] = await hre.ethers.getSigners();

    // CONFIGURE EDTION WITH SCHEMA FIRST

    // const edition = {
    //   seriesId: 1,
    //   editionId: 1,
    // };

    // await nftSchema.addEdition({
    //   ...edition,
    //   seriesName: "Generation 1",
    //   editionName: "Edition 1",
    // });

    // await nftSchema.addAttribute({
    //   attributeId: 1,
    //   traitType: "Rank",
    //   displayType: "number",
    //   values: [{ attributeId: 1, name: "1" }],
    // });

    // await nftSchema.addAttributes([
    //   {
    //     attributeId: 1,
    //     traitType: "Rank",
    //     displayType: "number",
    //     values: [{ name: "1" }, { name: "2" }, { name: "1000" }],
    //   },
    //   {
    //     attributeId: 2,
    //     traitType: "Power",
    //     values: [
    //       { name: hre.ethers.utils.formatBytes32String("Fire") },
    //       { name: hre.ethers.utils.formatBytes32String("Ice") },
    //       { name: hre.ethers.utils.formatBytes32String("Water") },
    //     ],
    //   },
    // ]);

    // await nftSchema.addType({
    //   ...edition,
    //   type: {
    //     typeId: 1,
    //     group: "Monster",
    //     name: "Frankenstein",
    //     description: "Frankenstein is a crazy monster",
    //     image: "SOME_IPFS_HASH",
    //     animation: "SOME_OTHER_IPFS_HASH",
    //   },
    // });

    // await nftSchema.assignAttributesToType({
    //   ...edition,
    //   typeId: 1,
    //   attributeIds: [1, 2],
    // });

    // // CONFIGURE EDTION WITH SCHEMA FIRST
    // // ##################

    // // now airdrop that Franky

    // await nft.airdrop(owner.address, 1, 1, 1, [
    //   {
    //     attributeId: 1,
    //     value: "1000",
    //   },
    //   {
    //     attributeId: 2,
    //     value: "Water",
    //   },
    // ]);

    // const tokenURI = await nft.tokenURI(1);
    // console.info(tokenURI);
    // const decoded = Buffer.from(tokenURI.split(",")[1], "base64").toString();

    // console.info(decoded);

    // const a = JSON.parse(
    //   '{"id":"1","name":"Unidonkey","description":"Test Description","image":"https://foo.bar/.png","attributes":[{"trait_type":"Series","value":"Generation 1"},{"trait_type":"Series ID","display_type":"number","value":"1"},{"trait_type":"Edition","value":"Edition 1"},{"trait_type":"Edition ID","display_type":"number","value":"1"},{"trait_type":"Type","value":"Unidonkey"},{"trait_type":"Color","value":"Red"},{"trait_type":"Horn","value":"Golden Horn"}]}'
    // );

    // expect(decoded).to.equal(
    //   '{"id":"1","name":"Unidonkey","description":"Test Description","image":"https://foo.bar/.png","attributes":[{"trait_type":"Series","value":"Generation 1"},{"trait_type":"Series ID","display_type":"number","value":"1"},{"trait_type":"Edition","value":"Edition 1"},{"trait_type":"Edition ID","display_type":"number","value":"1"},{"trait_type":"Type","value":"Unidonkey"},{"trait_type":"Color","value":"Red"},{"trait_type":"Horn","value":"Golden Horn"}]}'
    // );
  });
});
