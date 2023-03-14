// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

import "./Traits.sol";

/**
 * @dev NFTTraitDefintion is a trait that can be used in a NFTType. Its part of trait group. We might add more properties like porbality later on.
 */
struct NFTTraitDetails {
  bytes32 name;
}

/**
 * @dev NFTTraitType is a group of traits that are allowed to be used in a NFTType. E.g. color -> red, blue, green and horn -> long, short. Allowed values for displaytype are date, boost_number, boost_percentage, number or nothing.
 */
struct NFTTraitType {
  bytes32 traitType;
  bytes32 displayType;
  NFTTraitDetails[] traits;
}

/**
 * @dev NFTTypeSchema is a schema for a NFTType. It contains the allowed traits, group and description for a NFTType.
 */
struct NFTType {
  bytes32 group;
  bytes32 name;
  bytes description;
  // @dev mapping of trait group to the allowed list of traits
  // e.g. color -> red, blue, green and horn -> long, short
  NFTTraitType[] traitTypes;
}

/**
 * @dev NFTSchema is a schema for a set of NFTs. It contains the allowed types and the name of the series and edition.
 */
struct NFTEdition {
  uint16 seriesId;
  uint8 editionId;
  bytes32 seriesName;
  bytes32 editionName;
  NFTType[] allowedTypes;
}

/**
 * @dev NFTDefinition is a a helper to have all the information about a NFT defintion in one struct that is needed for metadate creation. The naming is bad.
 */
struct NFTDefinition {
  NFTEdition edition;
  NFTType nftType;
}
