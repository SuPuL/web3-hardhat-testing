// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "../libraries/NFTInstance.sol";
import "../libraries/NFTSchema.sol";
import "./INFTSchemaRepository.sol";

interface INFTRepository is INFTSchemaRepository {
  function craeteRandom(
    uint16 seriesId,
    uint8 editionId
  ) external view returns (NFTInstance memory);

  function create(
    uint16 seriesId,
    uint8 editionId,
    bytes32 typeName,
    NFTTrait[] calldata traits
  ) external view returns (NFTInstance memory);
}
