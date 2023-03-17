// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @dev NFTTraitDefintion is a trait that can be used in a NFTType. Its part of trait group. We might add more properties like porbality later on.
 */
struct NFTAttributeValue {
  uint16 attributeId;
  string value;
}

/**
 * @dev NFTTraitType is a group of traits that are allowed to be used in a NFTType. E.g. color -> red, blue, green and horn -> long, short. Allowed values for displaytype are date, boost_number, boost_percentage, number or nothing.
 */
struct NFTAttribute {
  uint16 attributeId;
  string traitType;
  string displayType;
  NFTAttributeValue[] values;
}

/**
 * @dev NFTTypeSchema is a schema for a NFTType. It contains the allowed traits, group and description for a NFTType.
 */
struct NFTType {
  uint16 typeId;
  string group;
  string name;
  // can be a code or ipfs hash
  string image;
  // can be a code or ipfs hash
  string animation;
  string description;
}

/**
 * @dev NFTSchema is a schema for a set of NFTs. It contains the allowed types and the name of the series and edition.
 */
struct NFTEdition {
  uint16 seriesId;
  uint8 editionId;
  string seriesName;
  string editionName;
}

struct NFTTrait {
  string traitType;
  string displayType;
  string value;
}

struct NFTDescription {
  NFTEdition edition;
  NFTType nftType;
  NFTTrait[] traits;
}

/**
 * @dev NFTStorageInfo is a struct that represents a single NFT instance. It has schemaTypeId which defined the series,
 * edition and type id. Using this is possible to get all static traits of this nft (e.g. horn, color etc.). Beside this it has a set of traits
 * that are custom for this instance. These are used for individual traits like type count or birthday etc.
 * Individual attributes might override the static traits.
 */
struct NFTStorageInfo {
  uint64 typeSchemaId;
  NFTTrait[] individualTraits;
  // @todo just store a hash and store the real values in the repository.
  NFTAttributeValue[] values;
}

/**
 * @dev NFTInstance is a struct that represents a single NFT instance. It has schemaTypeId and should have all relevante traits. Static or individual.
 */
struct NFTInstance {
  uint256 tokenId;
  NFTType nftType;
  NFTTrait[] traits;
}

library Traits {
  using Strings for uint;

  function get(
    string calldata traitType,
    string calldata traitName
  ) public pure returns (NFTTrait memory) {
    return NFTTrait(traitType, traitName, "");
  }

  function get(
    string calldata traitType,
    uint traitName
  ) public pure returns (NFTTrait memory) {
    return NFTTrait(traitType, traitName.toString(), "");
  }

  function get(
    string calldata traitType,
    uint traitName,
    string calldata displayType
  ) public pure returns (NFTTrait memory) {
    return NFTTrait(traitType, traitName.toString(), displayType);
  }

  function get(
    string calldata traitType,
    string calldata traitName,
    string calldata displayType
  ) public pure returns (NFTTrait memory) {
    return NFTTrait(traitType, traitName, displayType);
  }

  function merge(
    NFTTrait[] calldata left,
    NFTTrait[] calldata right
  ) public pure returns (NFTTrait[] memory traits) {
    traits = new NFTTrait[](left.length + right.length);

    for (uint256 i = 0; i < left.length; i++) {
      traits[i] = left[i];
    }

    for (uint256 i = 0; i < right.length; i++) {
      traits[left.length + i] = right[i];
    }
  }
}
