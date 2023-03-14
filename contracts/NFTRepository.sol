// SPDX-License-Identifier: none
// NFB Contracts v0.0.2
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/INFTFactory.sol";
import "./interfaces/INFTRepository.sol";

contract NFTRepository is Ownable, AccessControl, INFTRepository {
  bytes32 public constant FACTORY_MANAGER_ROLE =
    keccak256("FACTORY_MANAGER_ROLE");
  bytes32 public constant FACTORY_PRODUCER_ROLE =
    keccak256("FACTORY_PRODUCER_ROLE");

  // @todo optimize access maybe we build a types mapping -> edition + series
  mapping(uint16 => mapping(uint8 => INFTFactory)) private factories;
  mapping(uint16 => mapping(uint8 => NFTEdition)) private editions;

  constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(FACTORY_MANAGER_ROLE, msg.sender);
    _grantRole(FACTORY_PRODUCER_ROLE, msg.sender);
  }

  modifier onlyFactoryManager() {
    require(
      hasRole(FACTORY_MANAGER_ROLE, msg.sender),
      "NFTRepository: caller does not have the factory manager role"
    );
    _;
  }

  modifier onlyFactoryProducer() {
    require(
      hasRole(FACTORY_PRODUCER_ROLE, msg.sender),
      "NFTRepository: caller does not have the factory producer role"
    );
    _;
  }

  modifier onlySeriesAndEditionCreationAllowed(
    uint16 seriesId,
    uint8 editionId
  ) {
    require(
      factories[seriesId][editionId] != INFTFactory(address(0)) &&
        editions[seriesId][editionId].seriesId == seriesId &&
        editions[seriesId][editionId].editionId == editionId,
      "NFT: Series or edition is not available"
    );
    _;
  }

  function craeteRandom(
    uint16 seriesId,
    uint8 editionId
  ) external view returns (NFTInstance memory) {
    return _factory(seriesId, editionId).craeteRandom();
  }

  function create(
    uint16 seriesId,
    uint8 editionId,
    bytes32 typeName,
    NFTTrait[] calldata traitIdsToValues
  ) external view returns (NFTInstance memory) {
    return _factory(seriesId, editionId).create(typeName, traitIdsToValues);
  }

  function getEdition(
    uint16 seriesId,
    uint8 editionId
  ) external view returns (NFTEdition memory) {
    return editions[seriesId][editionId];
  }

  function getTypeDefintion(
    uint16 seriesId,
    uint8 editionId,
    bytes32 typeName
  ) external view returns (NFTDefinition memory) {
    NFTEdition memory edition = editions[seriesId][editionId];
    // @todo optimize access maybe we build a types mapping -> edition + series + typename
    for (uint256 i = 0; i < edition.allowedTypes.length; i++) {
      if (edition.allowedTypes[i].name == typeName) {
        return NFTDefinition(edition, edition.allowedTypes[i]);
      }
    }

    revert("NFT: Type not found");
  }

  function addEdition(NFTEdition calldata edition) external onlyFactoryManager {
    require(
      edition.seriesId > 0 && edition.editionId > 0,
      "NFT: Series or edition is not allowed"
    );

    require(
      editions[edition.seriesId][edition.editionId].seriesId == 0,
      "NFT: Series or edition already known"
    );

    editions[edition.seriesId][edition.editionId] = edition;
  }

  function setFactory(
    uint16 seriesId,
    uint8 editionId,
    INFTFactory factory
  ) external onlyFactoryManager {
    require(
      editions[seriesId][editionId].seriesId == seriesId &&
        editions[seriesId][editionId].editionId == editionId,
      "NFTRepository: Series or edition is not available"
    );

    factories[seriesId][editionId] = factory;
  }

  function _factory(
    uint16 seriesId,
    uint8 editionId
  )
    internal
    view
    onlyFactoryProducer
    onlySeriesAndEditionCreationAllowed(seriesId, editionId)
    returns (INFTFactory)
  {
    return factories[seriesId][editionId];
  }
}
