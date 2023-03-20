// SPDX-License-Identifier: none
// NFB Contracts v0.0.2
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "../../contracts/libraries/Types.sol";
import "../../contracts/NFTSchema.sol";

contract NFTSchemaTest is Test {
  using Strings for uint16;
  using Strings for uint8;

  NFTSchema private nftSchema;
  address owner;
  address user1;
  address user2;

  function setUp() public {
    nftSchema = new NFTSchema();
  }

  function testAddEdition() public {
    uint16 seriesId = 1;
    uint8 editionId = 1;

    NFTEdition memory edition = NFTEdition({
      seriesId: seriesId,
      editionId: editionId,
      seriesName: string.concat("Series ", seriesId.toString()),
      editionName: string.concat("Edition ", editionId.toString())
    });

    nftSchema.addEdition(edition);
    NFTEdition memory retrievedEdition = nftSchema.getEdition(
      seriesId,
      editionId
    );

    assertEq(retrievedEdition.seriesId, edition.seriesId);
    assertEq(retrievedEdition.editionId, edition.editionId);
  }
}
