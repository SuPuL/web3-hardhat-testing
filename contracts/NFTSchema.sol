// SPDX-License-Identifier: none
// NFB Contracts v0.0.2
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/INFTSchema.sol";
import "./libraries/Schema.sol";
import "./libraries/Types.sol";
import "./libraries/Set.sol";

contract NFTSchema is Ownable, AccessControl, INFTSchema {
  using Set for Set.ByInt16;
  using Set for Set.ByIntString;

  bytes32 public constant SCHEMA_MANAGER_ROLE =
    keccak256("SCHEMA_MANAGER_ROLE");

  bool internal schemaIsSealed;

  // schemaId to edition. Where the schemaId is a combination of seriesId and editionId
  mapping(uint32 => NFTEdition) editions;

  // schemaTypeId to schema type. Where the schemaTypeId is a combination of seriesId, editionId and typeId
  mapping(uint40 => NFTType) schemaTypes;

  // Attribute id to attributeØ
  mapping(uint16 => NFTAttribute) attributes;

  // as we wanne reuse attributes we need a lookup which attributes are allowed for a type
  // schemaTypeAttributeId lookup to attribute id
  mapping(uint40 => Set.ByInt16) internal typeAttributeLookup;

  // and we need a look for all allowed values of each attribute
  // attribute id to values
  mapping(uint16 => Set.ByIntString) internal attributeValueLookup;

  constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(SCHEMA_MANAGER_ROLE, msg.sender);
  }

  modifier onlySchemaManager() {
    require(
      hasRole(SCHEMA_MANAGER_ROLE, msg.sender),
      "Caller does not have the schema manager role."
    );
    _;
  }

  modifier isNotSealed() {
    require(!schemaIsSealed, "Schema is sealed and can not be changed.");
    _;
  }

  modifier isSealed() {
    require(schemaIsSealed, "Schema is not sealed.");
    _;
  }

  function addEdition(
    NFTEdition calldata edition
  ) external override onlySchemaManager isNotSealed returns (uint24 schemaId) {
    schemaId = Schema.getId(edition.seriesId, edition.editionId);
    require(editions[schemaId].editionId == 0, "Edition already exists.");
    editions[schemaId] = edition;
    emit EditionAdded(edition.seriesId, edition.editionId, schemaId);
  }

  function getEdition(
    uint16 seriesId,
    uint8 editionId
  ) public view returns (NFTEdition memory edition) {
    uint24 schemaId = Schema.getId(seriesId, editionId);
    require(
      editions[schemaId].editionId > 0,
      "Can't get an edition that doesn't exist."
    );
    edition = editions[schemaId];
  }

  function addType(
    uint16 seriesId,
    uint8 editionId,
    NFTType calldata nftType
  )
    external
    override
    onlySchemaManager
    isNotSealed
    returns (uint40 typeSchemaId)
  {
    typeSchemaId = Schema.getSchemaTypeId(seriesId, editionId, nftType.typeId);
    require(schemaTypes[typeSchemaId].typeId == 0, "Type already exists.");
    schemaTypes[typeSchemaId] = nftType;
    emit TypeAdded(seriesId, editionId, nftType.typeId, typeSchemaId);
  }

  function getType(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId
  ) public view returns (NFTType memory schemaType) {
    uint40 typeSchemaId = Schema.getSchemaTypeId(seriesId, editionId, typeId);
    require(
      schemaTypes[typeSchemaId].typeId > 0,
      "Can't get a type that doesn't exist."
    );
    schemaType = schemaTypes[typeSchemaId];
  }

  function addAttribute(NFTAttribute calldata attribute) external override {
    _addAttribute(attribute);
  }

  function addAttributes(
    NFTAttribute[] calldata newAttributes
  ) external override {
    for (uint i = 0; i < newAttributes.length; i++) {
      _addAttribute(newAttributes[i]);
    }
  }

  function getAttribute(
    uint16 attributeId
  ) external view returns (NFTAttribute memory attribute) {
    require(
      attributes[attributeId].attributeId > 0,
      "Can't get a attribute that doesn't exist."
    );
    attribute = attributes[attributeId];
  }

  function getAttributes(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId
  ) external view returns (NFTAttribute[] memory result) {
    uint40 typeSchemaId = Schema.getSchemaTypeId(seriesId, editionId, typeId);
    require(
      typeAttributeLookup[typeSchemaId].count() > 0,
      "Can't get attributes for a type that doesn't exist."
    );

    for (uint i = 0; i < typeAttributeLookup[typeSchemaId].count(); i++) {
      uint16 attributeId = typeAttributeLookup[typeSchemaId].keyList[i];
      result[i] = attributes[attributeId];
    }
  }

  function assignAttributeToType(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    uint16 attributeId
  ) external override {
    _assignAttributeToType(seriesId, editionId, typeId, attributeId);
  }

  function assignAttributesToType(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    uint16[] calldata attributeIds
  ) external override onlySchemaManager isNotSealed {
    for (uint i = 0; i < attributeIds.length; i++) {
      _assignAttributeToType(seriesId, editionId, typeId, attributeIds[i]);
    }
  }

  function supportsTypeInstance(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    NFTAttributeValue[] calldata values
  ) external view returns (bool) {
    uint40 schemaTypeId = Schema.getSchemaTypeId(seriesId, editionId, typeId);
    if (schemaTypes[schemaTypeId].typeId == 0) {
      return false;
    }

    // check if all attributes are allowed for this type
    for (uint16 i = 0; i < values.length; i++) {
      NFTAttributeValue calldata attrValue = values[i];
      if (
        !attributeValueLookup[attrValue.attributeId].exists(attrValue.value)
      ) {
        return false;
      }
    }

    return true;
  }

  function getDescription(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    NFTAttributeValue[] calldata values
  ) external view returns (NFTDescription memory instance) {
    uint40 schemaTypeId = Schema.getSchemaTypeId(seriesId, editionId, typeId);
    require(schemaTypes[schemaTypeId].typeId > 0, "Type not found.");
    instance.edition = getEdition(seriesId, editionId);
    instance.nftType = schemaTypes[schemaTypeId];
    instance.traits = _getTraits(schemaTypeId, values);
  }

  function seal() external override onlySchemaManager isNotSealed {
    schemaIsSealed = true;

    emit SchemaSealed();
  }

  function unseal() external override onlySchemaManager isSealed {
    schemaIsSealed = false;

    emit SchemaUnsealed();
  }

  function _getTraits(
    uint40 schemaTypeId,
    NFTAttributeValue[] calldata values
  ) internal view returns (NFTTrait[] memory traits) {
    for (uint16 i = 0; i < values.length; i++) {
      NFTAttributeValue calldata attrValue = values[i];
      traits[i] = _getTrait(
        schemaTypeId,
        attrValue.attributeId,
        attrValue.value
      );
    }

    require(values.length == traits.length, "Some trait is invalid.");
  }

  function _getTrait(
    uint40 schemaTypeId,
    uint16 attributeId,
    string calldata value
  ) internal view returns (NFTTrait memory trait) {
    require(
      typeAttributeLookup[schemaTypeId].exists(attributeId),
      "Attribute is not allowed for type."
    );
    require(
      attributes[attributeId].attributeId > 0,
      "Attribute value not allowed."
    );

    trait.displayType = attributes[attributeId].displayType;
    trait.traitType = attributes[attributeId].displayType;
    trait.value = value;
  }

  function _addAttribute(
    NFTAttribute calldata attribute
  ) internal onlySchemaManager isNotSealed {
    attributes[attribute.attributeId] = attribute;
    emit AttributeAdded(attribute.attributeId);
  }

  function _assignAttributeToType(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    uint16 attributeId
  ) internal onlySchemaManager isNotSealed {
    uint40 typeSchemaId = Schema.getSchemaTypeId(seriesId, editionId, typeId);
    require(schemaTypes[typeSchemaId].typeId > 0, "Type does not exist");
    require(
      attributes[attributeId].attributeId > 0,
      "Attribute does not exist."
    );

    NFTAttribute memory attribute = attributes[attributeId];
    typeAttributeLookup[typeSchemaId].insert(attributeId);
    // maybe move to extra method to save gas?
    for (uint i = 0; i < attribute.values.length; i++) {
      attributeValueLookup[attributeId].insert(attribute.values[i].value);
    }
  }
}
