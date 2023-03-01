// SPDX-License-Identifier: none
pragma solidity ^0.8.9;

import "./NFTSchema.sol";

struct NFTTraitMapping {
  bytes groupName;
  uint16 traitId;
}

struct NFTInstance {
  bytes description;
  uint16 seriesId;
  uint8 editionId;
  NFTType nftType;
  NFTTrait[] traits;
}
