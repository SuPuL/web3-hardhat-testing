import { expect } from "chai";
import hre from "hardhat";
import { Contract } from "@ethersproject/contracts";

const edition1 = {
  seriesId: 1,
  editionId: 1,
  seriesName: "Generation 1",
  editionName: "Edition 1",
};

const schemaId1 = 257;

describe("Schema contract ", () => {
  let nftSchema: Contract;

  beforeEach(async () => {
    // deploy schema library
    const Schema = await hre.ethers.getContractFactory("Schema");
    const schema = await Schema.deploy();
    await schema.deployed();

    // deploy NftSchema
    const NFTSchema = await hre.ethers.getContractFactory("NFTSchema", {
      libraries: { Schema: schema.address },
    });
    nftSchema = await NFTSchema.deploy();
    await nftSchema.deployed();
  });

  it("Should add an edition.", async () => {
    await expect(await nftSchema.addEdition({ ...edition1 }))
      .to.emit(nftSchema, "EditionAdded")
      .withArgs(edition1.seriesId, edition1.seriesId, schemaId1);
  });
});
