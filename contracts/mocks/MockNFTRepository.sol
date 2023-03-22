// SPDX-License-Identifier: none
// NFB Contracts v0.0.2
pragma solidity ^0.8.17;

import "../interfaces/INFTRepository.sol";
import "../libraries/Types.sol";
import "hardhat/console.sol";

contract MockNFTRepository is INFTRepository {
  function create(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    NFTAttributeValue[] calldata values
  ) external view returns (NFTStorageInfo memory) {
    console.log("seriesId: %s", seriesId);
    console.log("editionId: %s", editionId);
    console.log("typeId: %s", typeId);
    for (uint i = 0; i < values.length; i++) {
      console.log("values[%s]: %s", i, values[i].value);
    }

    revert("Not implemented yet");
  }

  function enrich(
    uint256 tokenId,
    NFTStorageInfo memory info
  ) external view returns (NFTInstance memory) {
    console.log("tokenId: %s", tokenId);
    console.log("editionId: %s", info.typeSchemaId);

    revert("Not implemented yet");
  }
}
