// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

import "./NFTSchema.sol";

struct NFTTrait {
  bytes32 traitType;
  bytes32 traitName;
}

/**
 * @dev NFTInstance is a struct that represents a single NFT instance. We should split this in a static and a dynamic part.
 * The static part that is the same for most types can be stored in one mapping and the individual part in another mapping.
 */
struct NFTInstance {
  uint16 seriesId;
  uint8 editionId;
  bytes32 typeName;
  NFTTrait[] traits;
}
