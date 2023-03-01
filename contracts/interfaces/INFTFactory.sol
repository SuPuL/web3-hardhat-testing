// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "../libraries/NFTInstance.sol";

interface INFTFactory {
  function craeteRandom() external view returns (NFTInstance memory);

  function create(
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    NFTTraitMapping[] calldata traitIdsToValues
  ) external view returns (NFTInstance memory);
}
