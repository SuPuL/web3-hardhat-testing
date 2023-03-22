// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

import "../../libraries/Schema.sol";
// import hardhat console
import "hardhat/console.sol";

contract MockSchemaLibraryWrapper {
  using Schema for uint24;
  using Schema for uint40;

  function getId(
    uint16 seriesId,
    uint8 editionId
  ) external pure returns (uint24 schemaId) {
    return Schema.getId(seriesId, editionId);
  }

  function splitId(
    uint24 schemaId
  ) external pure returns (uint16 seriesId, uint8 editionId) {
    return Schema.splitId(schemaId);
  }

  function getSchemaTypeId(
    uint24 schemaId,
    uint16 typeId
  ) external pure returns (uint40 schemaTypeId) {
    return Schema.getSchemaTypeId(schemaId, typeId);
  }

  function getSchemaTypeId(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId
  ) external pure returns (uint40 schemaTypeId) {
    return Schema.getSchemaTypeId(seriesId, editionId, typeId);
  }

  function splitSchemaTypeId(
    uint40 schemaTypeId
  ) external pure returns (uint16 seriesId, uint8 editionId, uint16 typeId) {
    return Schema.splitSchemaTypeId(schemaTypeId);
  }

  function extractIdFromSchemaTypeId(
    uint64 schemaTypeId
  ) external pure returns (uint24 schemaId) {
    return Schema.extractIdFromSchemaTypeId(schemaTypeId);
  }
}
