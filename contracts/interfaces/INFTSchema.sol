// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "../libraries/NFTSchema.sol";

interface INFTSchemaStorage {
  function types(uint256 _typeId) external view returns (NFTTypeSchema memory);

  function getType(
    uint256 _typeId
  ) external view returns (NFTTypeSchema memory);
}
