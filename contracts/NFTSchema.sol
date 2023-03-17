// SPDX-License-Identifier: none
// NFB Contracts v0.0.2
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/INFTSchema.sol";
import "./libraries/Schema.sol";
import "./libraries/Types.sol";
import "hardhat/console.sol";

contract NFTSchema is Ownable, AccessControl, INFTSchema {
  bytes32 public constant SCHEMA_MANAGER_ROLE =
    keccak256("SCHEMA_MANAGER_ROLE");

  bool internal schemaIsSealed;

  mapping(uint24 => NFTEdition) private editions;
  mapping(uint64 => NFTType) private schemaTypes;
  mapping(uint16 => NFTAttribute) private attributes;
  // as we wanne reuse attributes we need a lookup which attributes are allwed for a type
  mapping(uint64 => mapping(uint16 => bool)) private typeAttributeLookup;
  // and we need a look for all allowed values of each attribute
  mapping(uint16 => mapping(string => bool)) private attributeValueLookup;

  constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(SCHEMA_MANAGER_ROLE, msg.sender);
  }

  modifier onlySchemaManager() {
    require(
      hasRole(SCHEMA_MANAGER_ROLE, msg.sender),
      "NFTSchema: caller does not have the schema manager role"
    );
    _;
  }

  modifier isNotSealed() {
    require(!schemaIsSealed, "NFTSchema: is selaed and can not be changed");
    _;
  }

  function addEdition(
    NFTEdition calldata edition
  ) external override onlySchemaManager isNotSealed returns (uint24 schemaId) {
    schemaId = Schema.getId(edition.seriesId, edition.editionId);

    console.log("%s %s %s", edition.seriesId, edition.editionId, schemaId);

    require(
      editions[schemaId].seriesId == 0,
      "NFTSchema: edition already exists"
    );
    editions[schemaId] = edition;

    emit EditionAdded(edition.seriesId, edition.editionId, schemaId);
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
    returns (uint64 typeSchemaId)
  {
    typeSchemaId = Schema.getSchemaTypeId(seriesId, editionId, nftType.typeId);
    require(
      schemaTypes[typeSchemaId].typeId == 0,
      "NFTSchema: type already exists"
    );
    schemaTypes[typeSchemaId] = nftType;

    emit TypeAdded(seriesId, editionId, nftType.typeId, typeSchemaId);
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

  function getAttributes(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId
  ) external view returns (NFTAttribute[] memory) {}

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
    uint64 schemaTypeId = Schema.getSchemaTypeId(seriesId, editionId, typeId);
    if (schemaTypes[schemaTypeId].typeId == 0) {
      return false;
    }

    // check if all attributes are allowed for this type
    for (uint16 i = 0; i < values.length; i++) {
      NFTAttributeValue calldata attrValue = values[i];
      if (!attributeValueLookup[attrValue.attributeId][attrValue.value]) {
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
    uint64 schemaTypeId = Schema.getSchemaTypeId(seriesId, editionId, typeId);
    require(schemaTypes[schemaTypeId].typeId > 0, "NFTSchema: type not found");
    instance.edition = _getEdition(seriesId, editionId);
    instance.nftType = schemaTypes[schemaTypeId];
    instance.traits = _getTraits(schemaTypeId, values);
  }

  function seal() external override onlySchemaManager isNotSealed {
    schemaIsSealed = true;

    emit SchemaSealed();
  }

  function _getEdition(
    uint16 seriesId,
    uint8 editionId
  ) internal view returns (NFTEdition memory schema) {
    uint24 schemaId = Schema.getId(seriesId, editionId);
    require(editions[schemaId].editionId > 0, "NFTSchema: schema not found");
    return editions[schemaId];
  }

  function _getTraits(
    uint64 schemaTypeId,
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

    require(values.length == traits.length, "NFTSchema: invalid traits");
  }

  function _getTrait(
    uint64 schemaTypeId,
    uint16 attributeId,
    string calldata value
  ) internal view returns (NFTTrait memory trait) {
    require(
      typeAttributeLookup[schemaTypeId][attributeId],
      "NFTSchema: attribute not allowed for type"
    );
    require(
      attributeValueLookup[attributeId][value],
      "NFTSchema: attribute value not allowed"
    );

    trait.displayType = attributes[attributeId].displayType;
    trait.traitType = attributes[attributeId].displayType;
    trait.value = value;
  }

  function _addAttribute(
    NFTAttribute calldata attribute
  ) internal onlySchemaManager isNotSealed {
    console.log("adding attribute");
    require(
      attributes[attribute.attributeId].attributeId == 0,
      "NFTSchema: attribute already exists"
    );
    attributes[attribute.attributeId] = attribute;

    emit AttributeAdded(attribute.attributeId);
  }

  function _assignAttributeToType(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    uint16 attributeId
  ) internal onlySchemaManager isNotSealed {
    uint64 typeSchemaId = Schema.getSchemaTypeId(seriesId, editionId, typeId);
    require(
      schemaTypes[typeSchemaId].typeId > 0,
      "NFTSchema: type does not exist"
    );
    require(
      attributes[attributeId].attributeId > 0,
      "NFTSchema: attribute does not exist"
    );

    NFTAttribute memory attribute = attributes[attributeId];
    typeAttributeLookup[typeSchemaId][attributeId] = true;
    // maybe move to extra method to save gas?
    for (uint i = 0; i < attribute.values.length; i++) {
      attributeValueLookup[attributeId][attribute.values[i].value] = true;
    }
  }
}
