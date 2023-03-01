// SPDX-License-Identifier: none
pragma solidity ^0.8.9;

struct NFTTrait {
  uint16 id;
  bytes name;
  bytes2 codePrefix;
  uint8 code;
}

struct NFTType {
  uint16 id;
  bytes name;
  bytes2 codePrefix;
  uint8 code;
  bytes description;
}

struct NFTTraitGroup {
  bytes name;
  NFTTrait[] traits;
}

struct NFTTypeSchema {
  NFTType nftType;
  // @dev mapping of trait group to the allowed list of traits
  // e.g. color -> red, blue, green and horn -> long, short
  NFTTraitGroup[] allowedTraits;
}

struct NFTSchema {
  uint16 seriesId;
  uint8 editionId;
  bytes seriesName;
  bytes editionName;
  NFTTypeSchema[] allowedTypes;
}
