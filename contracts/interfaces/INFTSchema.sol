// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "../libraries/Schema.sol";
import "../libraries/Types.sol";

interface INFTSchema {
  /**
   * @dev Emitted when a new edition is added to the schema.
   *
   * @param seriesId Series for this edition
   * @param editionId Unique edition id for this series
   * @param schemaId The schamaId is an internal id based on edition and series id.
   */
  event EditionAdded(uint16 seriesId, uint8 editionId, uint24 schemaId);

  /**
   * @dev Emitted when a new type is added for the given edition.
   *
   * @param seriesId Series for this edition
   * @param editionId Unique edition id for this series
   * @param typeId Unique type id for this edition
   * @param typeSchemaId Internal id based on edition, series and type id.
   */
  event TypeAdded(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    uint64 typeSchemaId
  );

  /**
   * @dev Emitted when a new attribute is added to the schema. They are always global and can be reused over editions.
   *
   * @param attributeId Unique attribute id for this edition
   */
  event AttributeAdded(uint16 attributeId);

  /**
   * @dev Emitted after the schema was sealed. No more changes are allowed.
   */
  event SchemaSealed();

  function addEdition(
    NFTEdition calldata edition
  ) external returns (uint24 schemaId);

  function addType(
    uint16 seriesId,
    uint8 editionId,
    NFTType calldata nftType
  ) external returns (uint64 typeSchemaId);

  function addAttribute(NFTAttribute calldata attribute) external;

  function addAttributes(NFTAttribute[] calldata newAttributes) external;

  function assignAttributeToType(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    uint16 attributeId
  ) external;

  function assignAttributesToType(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    uint16[] calldata attributeIds
  ) external;

  function supportsTypeInstance(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    NFTAttributeValue[] calldata values
  ) external view returns (bool);

  function getDescription(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    NFTAttributeValue[] calldata values
  ) external view returns (NFTDescription memory instance);

  function seal() external;
}
