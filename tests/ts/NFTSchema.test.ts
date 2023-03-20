import { expect } from "chai";
import hre, { ethers } from "hardhat";
import { Contract, Signer } from "ethers";
import { faker } from "@faker-js/faker";

type Edition = {
  seriesId: number;
  editionId: number;
  seriesName: string;
  editionName: string;
};

const edition = (seriesId: number, editionId: number = 0): Edition => ({
  seriesId,
  editionId: editionId || seriesId,
  seriesName: `Generation ${seriesId}`,
  editionName: `Edition ${editionId || seriesId}`,
});

type Type = {
  typeId: number;
  group: string;
  name: string;
  image: string;
  animation: string;
  description: string;
};

const type = (typeId: number): Type => ({
  typeId,
  group: faker.name.jobType(),
  name: faker.hacker.noun(),
  image: faker.database.mongodbObjectId(),
  animation: faker.database.mongodbObjectId(),
  description: faker.lorem.paragraph(2),
});

describe("INFTSchema", () => {
  let NFTSchema: Contract;
  let owner: Signer;
  let addr1: Signer;
  let addr2: Signer;

  beforeEach(async () => {
    // deploy schema library
    const Schema = await hre.ethers.getContractFactory("Schema");
    const schema = await Schema.deploy();
    await schema.deployed();

    const INFTSchemaFactory = await ethers.getContractFactory("NFTSchema", {
      libraries: { Schema: schema.address },
    });
    [owner, addr1, addr2] = await ethers.getSigners();
    NFTSchema = await INFTSchemaFactory.deploy();
    await NFTSchema.deployed();
  });

  describe("Edition", () => {
    const sampleEdition = edition(1);

    it("Should add a new edition by the owner", async () => {
      await expect(
        NFTSchema.callStatic.getEdition(
          sampleEdition.seriesId,
          sampleEdition.editionId
        )
      ).to.be.revertedWith("Can't get an edition that doesn't exist.");

      await NFTSchema.connect(owner).addEdition(sampleEdition);
      const newEdition = await NFTSchema.callStatic.getEdition(
        sampleEdition.seriesId,
        sampleEdition.editionId
      );

      expect(newEdition.seriesId).to.equal(sampleEdition.seriesId);
      expect(newEdition.editionId).to.equal(sampleEdition.editionId);
    });

    // Should not be able to add an edition with the same seriesId and editionId
    it("Should revert if the edition already exists", async () => {
      const sampleEdition2: Edition = edition(1, 2);
      await NFTSchema.connect(owner).addEdition(sampleEdition2);
      await expect(
        NFTSchema.connect(owner).addEdition(sampleEdition2)
      ).to.be.revertedWith("Edition already exists.");
    });

    it("Should emit EditionAdded event", async () => {
      await expect(NFTSchema.connect(owner).addEdition(sampleEdition)).to.emit(
        NFTSchema,
        "EditionAdded"
      );
    });

    it("Should revert if called by a non-owner", async () => {
      await expect(
        NFTSchema.connect(addr1).addEdition(sampleEdition)
      ).to.be.revertedWith("Caller does not have the schema manager role.");
    });

    // Should test that you cannot add an edition if the schema is sealed
    it("Should revert if the schema is sealed", async () => {
      await NFTSchema.connect(owner).seal();
      await expect(
        NFTSchema.connect(owner).addEdition(edition(1))
      ).to.be.revertedWith("Schema is sealed and can not be changed.");
    });
  });

  describe("Type", () => {
    let sampleType = type(1);
    let sampleEdition: Edition;

    beforeEach(async () => {
      sampleEdition = edition(1);
      await NFTSchema.connect(owner).addEdition(sampleEdition);
    });

    it("Should add a new type for the given edition", async () => {
      // const { editionId, seriesId } = sampleEdition;
      // await expect(
      //   NFTSchema.callStatic.getType(seriesId, editionId, sampleType.typeId)
      // ).to.be.revertedWith("Can't get a type that doesn't exist.");
      // await NFTSchema.connect(owner).addType(seriesId, editionId, sampleType);
      // const newType = await NFTSchema.callStatic.getType(
      //   seriesId,
      //   editionId,
      //   sampleType.typeId
      // );
      // console.info(Object.getOwnPropertyNames(newType));
      // expect(newType).to.own.contains(sampleType);
    });
  });

  describe("addAttribute", () => {
    it("Should add a new attribute", async () => {
      // TODO: Implement the test for adding a new attribute
    });
  });

  describe("addAttributes", () => {
    it("Should add multiple new attributes", async () => {
      // TODO: Implement the test for adding multiple new attributes
    });
  });

  describe("assignAttributeToType", () => {
    it("Should assign an attribute to a type", async () => {
      // TODO: Implement the test for assigning an attribute to a type
    });
  });

  describe("assignAttributesToType", () => {
    it("Should assign multiple attributes to a type", async () => {
      // TODO: Implement the test for assigning multiple attributes to a type
    });
  });
  describe("supportsTypeInstance", () => {
    it("Should check if the schema supports a type instance", async () => {
      // TODO: Implement the test for checking if the schema supports a type instance
    });
  });

  describe("getDescription", () => {
    it("Should return the description for a given type instance", async () => {
      // TODO: Implement the test for getting the description of a type instance
    });
  });

  describe("seal", () => {
    it("Should seal the schema", async () => {
      // TODO: Implement the test for sealing the schema
    });
  });
});
