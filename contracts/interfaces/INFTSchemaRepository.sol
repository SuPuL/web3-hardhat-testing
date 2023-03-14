// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "../libraries/NFTInstance.sol";
import "../libraries/NFTSchema.sol";

interface INFTSchemaRepository {
  function getEdition(
    uint16 seriesId,
    uint8 editionId
  ) external view returns (NFTEdition memory);

  function getTypeDefintion(
    uint16 seriesId,
    uint8 editionId,
    bytes32 typeName
  ) external view returns (NFTDefinition memory);

  function addEdition(NFTEdition calldata edition) external;
}
