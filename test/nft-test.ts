import { expect } from "chai";
import hre from "hardhat";
import { Contract } from "@ethersproject/contracts";

describe("NFT Contract", () => {
  const ADMIN = "0x1234567890123456789012345678901234567890";
  const MINTER = "0x2345678901234567890123456789012345678901";
  const AIRDROP_MANAGER = "0x3456789012345678901234567890123456789012";

  let nft: Contract;

  beforeEach(async () => {
    const [owner] = await hre.ethers.getSigners();

    const NFT = await hre.ethers.getContractFactory("NFT");
    const nft = await NFT.deploy();
    await nft.deployed();
    await nft.grantRole(0, ADMIN);
    await nft.grantRole(1, MINTER);
    await nft.grantRole(2, AIRDROP_MANAGER);
  });

  it("grants the correct roles", async () => {
    const actualAdmin = await nft.getRoleMember(0);
    const actualMinter = await nft.getRoleMember(1);
    const actualAirdropManager = await nft.getRoleMember(2);

    expect(actualAdmin).to.equal(ADMIN);
    expect(actualMinter).to.equal(MINTER);
    expect(actualAirdropManager).to.equal(AIRDROP_MANAGER);
  });

  it("only allows the admin to grant roles", async () => {
    await expect(nft.methods.grantRole(0, MINTER).send({ from: MINTER })).to.be
      .reverted;
  });
});
