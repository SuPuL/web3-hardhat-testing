// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "../libraries/Schema.sol";
import "../libraries/Types.sol";

interface INFTSchema {
  /**
   * @dev Emitted when a new series is added to the schema.
   *
   * @param seriesId Series id
   */
  event SeriesAdded(uint16 seriesId);

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

  /**
   * @dev Emitted after the schema was sealed. No more changes are allowed.
   */
  event SchemaUnsealed();

  /**
   * @dev Emitted after an edtion was sealed. No more changes are allowed.
   *
   * @param seriesId Series for this edition
   * @param editionId Unique edition id for this series
   * @param schemaId The schamaId is an internal id based on edition and series id.
   */
  event EditionSealed(uint16 seriesId, uint8 editionId, uint24 schemaId);

  /**
   * @dev Emitted after the schema was sealed. No more changes are allowed.
   *
   * @param seriesId Series for this edition
   * @param editionId Unique edition id for this series
   * @param schemaId The schamaId is an internal id based on edition and series id.
   */
  event EditionUnsealed(uint16 seriesId, uint8 editionId, uint24 schemaId);

  function addEdition(NFTEdition calldata edition) external returns (uint24);

  function getEdition(
    uint16 seriesId,
    uint8 editionId
  ) external view returns (NFTEdition memory);

  function addType(
    uint16 seriesId,
    uint8 editionId,
    NFTType calldata nftType
  ) external returns (uint40);

  function getType(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId
  ) external view returns (NFTType memory);

  function addAttribute(NFTAttribute calldata attribute) external;

  function addAttributes(NFTAttribute[] calldata newAttributes) external;

  function getAttribute(
    uint16 attributeId
  ) external view returns (NFTAttribute memory);

  function getAttributes(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId
  ) external view returns (NFTAttribute[] memory);

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

  function unseal() external;

  function sealEdition(uint16 seriesId, uint8 editionId) external;

  function unsealEdition(uint16 seriesId, uint8 editionId) external;
}
