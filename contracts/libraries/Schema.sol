// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

import "hardhat/console.sol";

library Schema {
  function getId(
    uint16 seriesId,
    uint8 editionId
  ) public pure returns (uint24 schemaId) {
    require(seriesId > 0, "SeriesId must be greater than 0");
    require(editionId > 0, "EditionId must be greater than 0");
    // Shift the uint16 value left by 8 bits to make room for the uint8 value
    // Add the uint8 value to the uint24 value
    schemaId = (seriesId << 8) | editionId;
  }

  function splitId(
    uint24 schemaId
  ) public pure returns (uint16 seriesId, uint8 editionId) {
    require(schemaId > 0, "SchemaId must be greater than 0");
    // Mask the top 8 bits of the uint24 value to get the uint8 value
    editionId = uint8(schemaId & 0xFF);
    // Shift the uint24 value right by 8 bits to get the uint16 value
    seriesId = uint16(schemaId >> 8);
  }

  function getSchemaTypeId(
    uint24 schemaId,
    uint16 typeId
  ) public pure returns (uint40 schemaTypeId) {
    require(schemaId > 0, "SchemaId must be greater than 0");
    require(typeId > 0, "TypeId must be greater than 0");
    schemaTypeId = (schemaId << 16) | typeId;
  }

  function getSchemaTypeId(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId
  ) public pure returns (uint40 schemaTypeId) {
    require(seriesId > 0, "SeriesId must be greater than 0");
    require(editionId > 0, "EditionId must be greater than 0");
    require(typeId > 0, "TypeId must be greater than 0");
    // Shift the uint16 value left by 8 bits to make room for the uint8 value
    // Add the uint8 value to the uint24 value
    // Join all three ids to one uint
    schemaTypeId = getSchemaTypeId(getId(seriesId, editionId), typeId);
  }

  function splitSchemaTypeId(
    uint40 schemaTypeId
  ) public pure returns (uint16 seriesId, uint8 editionId, uint16 typeId) {
    require(schemaTypeId > 0, "SchemaTypeId must be greater than 0");
    // Mask the top 8 bits of the uint24 value to get the uint8 value
    typeId = uint16(schemaTypeId & 0xFFFF);
    // Shift the uint24 value right by 8 bits to get the uint16 value
    editionId = uint8((schemaTypeId >> 16) & 0xFF);
    seriesId = uint16(schemaTypeId >> 24);
  }

  function extractIdFromSchemaTypeId(
    uint64 schemaTypeId
  ) public pure returns (uint24 schemaId) {
    require(schemaTypeId > 0, "SchemaTypeId must be greater than 0");
    // Shift the uint24 value right by 16 bits to get the uint24 value
    schemaId = uint24(schemaTypeId >> 16);
  }
}
