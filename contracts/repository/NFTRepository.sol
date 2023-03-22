// SPDX-License-Identifier: none
// NFB Contracts v0.0.2
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ANFTProxyRepository.sol";
import "../interfaces/INFTRepository.sol";
import "../interfaces/INFTSchema.sol";
import "../libraries/Types.sol";
import "hardhat/console.sol";

contract NFTRepository is ANFTProxyRepository {
  INFTSchema internal schema;

  constructor(address _schema) ANFTProxyRepository() {
    schema = INFTSchema(_schema);
  }

  function create(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    NFTAttributeValue[] calldata values
  ) external view onlyProducer returns (NFTStorageInfo memory instance) {
    require(
      schema.supportsTypeInstance(seriesId, editionId, typeId, values),
      "NFT: type not supported"
    );

    // get the individual traits. Only birthday atm.
    instance.typeSchemaId = Schema.getSchemaTypeId(seriesId, editionId, typeId);
    instance.individualTraits = new NFTTrait[](1);
    instance.individualTraits[0] = Traits.get(
      "Birthday",
      block.timestamp,
      "date"
    );
    instance.values = values;
  }

  function enrich(
    uint256 tokenId,
    NFTStorageInfo memory info
  ) external view onlyProducer returns (NFTInstance memory instance) {
    require(tokenId > 0, "NFT: id is not valid");

    (uint16 seriesId, uint8 editionId, uint16 typeId) = Schema
      .splitSchemaTypeId(info.typeSchemaId);

    require(
      schema.supportsTypeInstance(seriesId, editionId, typeId, info.values),
      "NFT: type not supported"
    );

    NFTDescription memory description = schema.getDescription(
      seriesId,
      editionId,
      typeId,
      info.values
    );

    require(
      description.nftType.typeId != typeId &&
        description.edition.editionId != editionId &&
        description.edition.seriesId != seriesId,
      "NFT: description seems invalid"
    );

    instance.tokenId = tokenId;
    instance.nftType = description.nftType;
    instance.traits = Traits.merge(description.traits, info.individualTraits);
  }

  function setSchema(address _schema) external onlyManager {
    schema = INFTSchema(_schema);
  }
}
