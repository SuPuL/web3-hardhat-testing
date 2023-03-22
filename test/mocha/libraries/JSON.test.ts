import { expect } from "chai";
import hre from "hardhat";
import { Contract } from "ethers";

describe("JSON Library", function () {
  let MockJSONLibraryWrapper;
  let jsonWrapper: Contract;

  beforeEach(async function () {
    // deploy schema library
    const JSON = await hre.ethers.getContractFactory("JSON");
    const json = await JSON.deploy();
    await json.deployed();

    MockJSONLibraryWrapper = await hre.ethers.getContractFactory(
      "MockJSONLibraryWrapper",
      {
        libraries: { JSON: json.address },
      }
    );
    jsonWrapper = await MockJSONLibraryWrapper.deploy();
    await jsonWrapper.deployed();
  });

  describe("prop", function () {
    it("should return a JSON property correctly", async function () {
      const key = "name";
      const value = "example";
      const expectedProp = '"name":"example"';

      expect(await jsonWrapper.prop(key, value)).to.equal(expectedProp);
    });
  });

  describe("obj", function () {
    it("should return a JSON object correctly", async function () {
      const properties = ['"name":"example"', '"age":30'];
      const expectedObj = '{"name":"example","age":30}';

      expect(await jsonWrapper.obj(properties)).to.equal(expectedObj);
    });
  });

  describe("arr", function () {
    it("should return a JSON array correctly", async function () {
      const values = ['"example"', "30", '"test"'];
      const expectedArr = '["example",30,"test"]';

      expect(await jsonWrapper.arr(values)).to.equal(expectedArr);
    });
  });

  // Add more tests for other functions here
});
