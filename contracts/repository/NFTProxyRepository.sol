// SPDX-License-Identifier: none
// NFB Contracts v0.0.2
pragma solidity ^0.8.17;

import "./ANFTProxyRepository.sol";
import "../interfaces/INFTRepository.sol";

contract NFTProxyRepository is ANFTProxyRepository {
  mapping(uint24 => INFTRepository) internal factories;
  INFTRepository internal defaultBuildRepository;
  bool internal allowRepositoryOverride;

  function craeteRandom(
    uint16 seriesId,
    uint8 editionId
  ) external view onlyProducer returns (NFTStorageInfo memory) {
    return getRepository(seriesId, editionId).craeteRandom(seriesId, editionId);
  }

  function create(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    NFTAttributeValue[] calldata values
  ) external view onlyProducer returns (NFTStorageInfo memory) {
    return
      getRepository(seriesId, editionId).create(
        typeId,
        editionId,
        typeId,
        values
      );
  }

  function enrich(
    uint256 tokenId,
    NFTStorageInfo memory info
  ) external view returns (NFTInstance memory) {
    return getRepository(info.typeSchemaId).enrich(tokenId, info);
  }

  function setBuildRepository(
    uint16 seriesId,
    uint8 editionId,
    INFTRepository buildRepository
  ) external onlyManager {
    uint24 schemaId = Schema.getId(seriesId, editionId);
    require(
      factories[schemaId] != INFTRepository(address(0)) ||
        allowRepositoryOverride,
      "NFT: repository already set"
    );
    factories[schemaId] = buildRepository;
  }

  function setDefaultRepository(
    INFTRepository repository
  ) external onlyManager {
    defaultBuildRepository = repository;
  }

  function setAllowRepositoryOverride(
    bool _allowRepositoryOverride
  ) external onlyManager {
    allowRepositoryOverride = _allowRepositoryOverride;
  }

  function getRepository(
    uint16 seriesId,
    uint8 editionId
  ) internal view onlyProducer returns (INFTRepository) {
    uint24 schemaId = Schema.getId(seriesId, editionId);
    return _getRepository(schemaId);
  }

  function getRepository(
    uint64 schemaTypeId
  ) internal view onlyProducer returns (INFTRepository) {
    uint24 schemaId = Schema.extractIdFromSchemaTypeId(schemaTypeId);
    return _getRepository(schemaId);
  }

  function _getRepository(
    uint24 schemaId
  ) internal view onlyProducer returns (INFTRepository) {
    INFTRepository repository = factories[schemaId];
    if (repository == INFTRepository(address(0))) {
      repository = defaultBuildRepository;
    }

    return repository;
  }
}
