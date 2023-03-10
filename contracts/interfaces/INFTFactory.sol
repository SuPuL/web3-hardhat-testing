// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "../libraries/NFTInstance.sol";
import "../libraries/NFTSchema.sol";

interface INFTFactory {
  function craeteRandom() external view returns (NFTInstance memory);

  function create(
    bytes32 typeName,
    NFTTrait[] calldata traits
  ) external view returns (NFTInstance memory);
}
