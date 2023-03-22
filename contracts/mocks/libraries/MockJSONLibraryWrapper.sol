// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../../libraries/Types.sol";
import "../../libraries/JSON.sol";

contract MockJSONLibraryWrapper {
  using JSON for string[];
  using JSON for NFTTrait[];

  function prop(
    string calldata key,
    string calldata value
  ) external pure returns (string memory) {
    return JSON.prop(key, value);
  }

  function obj(
    string[] calldata properties
  ) external pure returns (string memory) {
    return JSON.obj(properties);
  }

  function arr(
    string[] calldata values
  ) external pure returns (string memory output) {
    return JSON.arr(values);
  }

  function encode(
    NFTTrait[] calldata traits
  ) external pure returns (string memory) {
    return JSON.encode(traits);
  }

  function encodeTrait(
    NFTTrait calldata trait
  ) external pure returns (string memory) {
    return JSON.encode(trait);
  }

  function encodeWithDisplayType(
    string calldata traitType,
    string calldata value,
    string calldata displayType
  ) external pure returns (string memory) {
    return JSON.encode(traitType, value, displayType);
  }

  function encodeWithoutDisplayType(
    string calldata traitType,
    string calldata value
  ) external pure returns (string memory) {
    return JSON.encode(traitType, value);
  }

  function isNumber(string calldata displayType) external pure returns (bool) {
    return JSON.isNumber(displayType);
  }
}
