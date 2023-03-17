// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./Types.sol";

library JSON {
  using Strings for uint16;

  function prop(
    string calldata key,
    string calldata value
  ) public pure returns (string memory) {
    return string.concat('"', key, '":"', value, '"');
  }

  function obj(
    string[] calldata properties
  ) public pure returns (string memory) {
    string memory output = "{";
    for (uint256 i = 0; i < properties.length; i++) {
      output = string.concat(output, properties[i]);
    }

    return string.concat(output, "}");
  }

  function arr(
    string[] memory values
  ) public pure returns (string memory output) {
    for (uint256 i = 0; i < values.length; i++) {
      output = string.concat(output, values[i]);
      if (i < values.length - 1) {
        output = string.concat(output, ",");
      }
    }
    output = string.concat("[", output, "]");
  }

  function encode(
    NFTTrait[] calldata traits
  ) public pure returns (string memory) {
    string[] memory input;
    for (uint256 i = 0; i < traits.length; i++) {
      input[i] = encode(traits[i]);
    }

    return arr(input);
  }

  function encode(NFTTrait calldata trait) public pure returns (string memory) {
    if (bytes(trait.displayType).length == 0) {
      return encode(trait.traitType, trait.value);
    }

    return encode(trait.traitType, trait.value, trait.displayType);
  }

  function encode(
    string calldata traitType,
    string calldata value,
    string calldata displayType
  ) public pure returns (string memory) {
    string memory valueString = value;
    if (!isNumber(displayType)) {
      valueString = string.concat('"', displayType, '","value":"');
    }

    return
      string.concat(
        '{"trait_type":"',
        traitType,
        '","display_type":"',
        displayType,
        '","value":',
        valueString,
        "}"
      );
  }

  function encode(
    string calldata traitType,
    string calldata value
  ) public pure returns (string memory) {
    return
      string.concat('{"trait_type":"', traitType, '","value":"', value, '"}');
  }

  function isNumber(string calldata displayType) public pure returns (bool) {
    bytes32 hash = keccak256(abi.encodePacked(displayType));

    return
      hash == keccak256(abi.encodePacked("date")) ||
      hash == keccak256(abi.encodePacked("number")) ||
      hash == keccak256(abi.encodePacked("boost_number")) ||
      hash == keccak256(abi.encodePacked("boost_percentage"));
  }
}
