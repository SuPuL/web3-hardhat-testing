import { expect } from "chai";
import hre, { ethers } from "hardhat";
import { Contract, BigNumber } from "ethers";

const MAX_UINT_24 = (2 ^ 24) - 1;
const MAX_UINT_16 = (2 ^ 16) - 1;
const MAX_UINT_8 = (2 ^ 8) - 1;

describe("Schema Library", function () {
  let MockSchemaLibraryWrapperFactory;
  let schema: Contract;

  beforeEach(async function () {
    // deploy schema library
    const Schema = await hre.ethers.getContractFactory("Schema");
    const schemaLib = await Schema.deploy();
    await schemaLib.deployed();

    MockSchemaLibraryWrapperFactory = await ethers.getContractFactory(
      "MockSchemaLibraryWrapper",
      {
        libraries: { Schema: schemaLib.address },
      }
    );
    schema = await MockSchemaLibraryWrapperFactory.deploy();
    await schema.deployed();
  });

  describe("getId", function () {
    it("should return the correct schema ID", async function () {
      const seriesId = 1;
      const editionId = 2;
      const expectedSchemaId = (1 << 8) | 2;

      expect(await schema.getId(seriesId, editionId)).to.equal(
        expectedSchemaId
      );
    });
  });

  describe("splitId", function () {
    it("should split the schema ID correctly", async function () {
      const schemaId = 257;
      const expectedSeriesId = 1;
      const expectedEditionId = 1;

      const [seriesId, editionId] = await schema.splitId(schemaId);
      expect(seriesId).to.equal(expectedSeriesId);
      expect(editionId).to.equal(expectedEditionId);
    });
  });

  describe("getSchemaTypeId", function () {
    const testSchemaTypeIdFor2 = async (schemaId: number, typeId: number) => {
      const uint24Value = BigNumber.from(schemaId); // convert string to uint24 BigNumber
      const uint16Value = BigNumber.from(typeId); // convert string to uint16 BigNumber
      const concatenatedValue = uint24Value.shl(16).or(uint16Value); // shift uint24 value by 16 bits and OR with uint16 value
      const expectedSchemaTypeId =
        concatenatedValue.toNumber() % Math.pow(2, 40); // convert to uint40 using modulo operator

      const schemaTypeId = await schema["getSchemaTypeId(uint24,uint16)"](
        schemaId,
        typeId
      );

      expect(schemaTypeId).to.equal(expectedSchemaTypeId);
    };

    describe("should return the correct schema type ID with schema ID and type ID", function () {
      it("dd uint24 and uint16", async () => {
        testSchemaTypeIdFor2(-155555, 0);
      });

      it("min uint24 and uint16", async () => {
        testSchemaTypeIdFor2(0, 0);
      });

      it("realistic uint24 and uint16", async () => {
        testSchemaTypeIdFor2(50, 19);
      });

      it("max uint24 and uint16", async () => {
        testSchemaTypeIdFor2(2 ^ (24 - 1), 2 ^ (16 - 1));
      });
    });

    const testSchemaTypeIdFor3 = async (
      seriesId: number,
      editionId: number,
      typeId: number
    ) => {
      const uint24Value = BigNumber.from(seriesId); // convert string to uint24 BigNumber
      const uint8Value = BigNumber.from(editionId); // convert string to uint8 BigNumber
      const uint16Value = BigNumber.from(typeId); // convert string to uint16 BigNumber
      const concatenatedValue = uint24Value
        .shl(8)
        .or(uint8Value)
        .shl(16)
        .or(uint16Value); // shift uint24 value by 16 bits and OR with uint16 value
      const expectedSchemaTypeId =
        concatenatedValue.toNumber() % Math.pow(2, 40); // convert to uint24 using modulo operator

      const schemaTypeId = await schema["getSchemaTypeId(uint16,uint8,uint16)"](
        seriesId,
        editionId,
        typeId
      );

      expect(schemaTypeId).to.equal(expectedSchemaTypeId);
    };

    describe("should return the correct schema type ID with series ID, edition ID, and type ID", function () {
      it("min uint16, uint8 and uint16", async () => {
        testSchemaTypeIdFor3(0, 0, 0);
      });

      it("realistic uint16, uint8 and uint16", async () => {
        testSchemaTypeIdFor3(50, 1, 19);
      });

      it("max uint16, uint8 and uint16", async () => {
        testSchemaTypeIdFor3(MAX_UINT_16, MAX_UINT_8, MAX_UINT_16);
      });
    });
  });

  describe("splitSchemaTypeId", function () {
    it("should split the schema type ID correctly", async function () {
      const schemaTypeId = 131586;
      const expectedSeriesId = 2;
      const expectedEditionId = 1;
      const expectedTypeId = 10;

      const [seriesId, editionId, typeId] = await schema.splitSchemaTypeId(
        schemaTypeId
      );
      expect(seriesId).to.equal(expectedSeriesId);
      expect(editionId).to.equal(expectedEditionId);
      expect(typeId).to.equal(expectedTypeId);
    });
  });

  describe("extractIdFromSchemaTypeId", function () {
    it("should extract the correct schema ID from schema type ID", async function () {
      const schemaTypeId = BigInt(131586);
      const expectedSchemaId = 513;

      expect(await schema.extractIdFromSchemaTypeId(schemaTypeId)).to.equal(
        expectedSchemaId
      );
    });
  });
});
