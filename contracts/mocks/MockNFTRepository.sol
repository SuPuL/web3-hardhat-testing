// SPDX-License-Identifier: none
// NFB Contracts v0.0.2
pragma solidity ^0.8.17;

import "../interfaces/INFTRepository.sol";
import "../libraries/Types.sol";

contract MockNFTRepository is INFTRepository {
  function craeteRandom(
    uint16 seriesId,
    uint8 editionId
  ) external view returns (NFTStorageInfo memory) {
    revert("Not implemented yet");
  }

  function create(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    NFTAttributeValue[] calldata values
  ) external view returns (NFTStorageInfo memory) {
    // return
    //   NFTStorageInfo({seriesId: 1, editionId: 1, typeId: typeId, traits: traits});
    revert("Not implemented yet");
  }

  function enrich(
    uint256 tokenId,
    NFTStorageInfo memory info
  ) external view returns (NFTInstance memory) {
    revert("Not implemented yet");
  }
}
