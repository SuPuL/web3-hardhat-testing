// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "../libraries/Schema.sol";
import "../libraries/Types.sol";

interface INFTRepository {
  function craeteRandom(
    uint16 seriesId,
    uint8 editionId
  ) external view returns (NFTStorageInfo memory);

  function create(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    NFTAttributeValue[] calldata values
  ) external view returns (NFTStorageInfo memory);

  function enrich(
    uint256 tokenId,
    NFTStorageInfo memory info
  ) external view returns (NFTInstance memory);
}
