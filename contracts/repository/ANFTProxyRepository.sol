// SPDX-License-Identifier: none
// NFB Contracts v0.0.2
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/INFTRepository.sol";

abstract contract ANFTProxyRepository is
  Ownable,
  AccessControl,
  INFTRepository
{
  bytes32 public constant REPOSITORY_MANAGER_ROLE =
    keccak256("REPOSITORY_MANAGER_ROLE");
  bytes32 public constant REPOSITORY_PRODUCER_ROLE =
    keccak256("REPOSITORY_PRODUCER_ROLE");

  constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(REPOSITORY_MANAGER_ROLE, msg.sender);
    _grantRole(REPOSITORY_PRODUCER_ROLE, msg.sender);
  }

  modifier onlyManager() {
    require(
      hasRole(REPOSITORY_MANAGER_ROLE, msg.sender),
      "NFTRepository: caller does not have the repository manager role"
    );
    _;
  }

  modifier onlyProducer() {
    require(
      hasRole(REPOSITORY_PRODUCER_ROLE, msg.sender),
      "NFTRepository: caller does not have the repository producer role"
    );
    _;
  }
}
