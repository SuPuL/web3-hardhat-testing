// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

library Traits {
  struct Trait {
    bytes32 traitType;
    bytes traitName;
    bytes32 displayType;
  }

  function get(
    bytes32 traitType,
    bytes calldata traitName
  ) public pure returns (Trait memory) {
    return Trait(traitType, traitName, 0);
  }

  function get(
    bytes32 traitType,
    uint16 traitName
  ) public pure returns (Trait memory) {
    return Trait(traitType, abi.encodePacked(traitName), 0);
  }

  function get(
    bytes32 traitType,
    bytes32 traitName
  ) public pure returns (Trait memory) {
    return Trait(traitType, abi.encodePacked(traitName), 0);
  }

  function get(
    bytes32 traitType,
    bytes calldata traitName,
    bytes32 displayType
  ) public pure returns (Trait memory) {
    return Trait(traitType, traitName, displayType);
  }

  function get(
    bytes32 traitType,
    uint16 traitName,
    bytes32 displayType
  ) public pure returns (Trait memory) {
    return Trait(traitType, abi.encodePacked(traitName), displayType);
  }

  function get(
    bytes32 traitType,
    bytes32 traitName,
    bytes32 displayType
  ) public pure returns (Trait memory) {
    return Trait(traitType, abi.encodePacked(traitName), displayType);
  }

  function encode(Trait[] calldata traits) public pure returns (string memory) {
    bytes memory output;
    for (uint256 i = 0; i < traits.length; i++) {
      output = abi.encodePacked(output, encode(traits[i]));
    }

    return string(abi.encodePacked("[", output, "]"));
  }

  function encode(Trait calldata trait) public pure returns (string memory) {
    if (trait.displayType == "") {
      return encode(trait.traitType, trait.traitName);
    }

    return encode(trait.traitType, trait.traitName, trait.displayType);
  }

  function encode(
    bytes32 traitType,
    bytes calldata traitName,
    bytes32 displayType
  ) public pure returns (string memory) {
    return
      string(
        abi.encodePacked(
          '{"trait_type":"',
          traitType,
          '","display_type":"',
          displayType,
          '","value":"',
          traitName,
          '"}'
        )
      );
  }

  function encode(
    bytes32 traitType,
    bytes calldata traitName
  ) public pure returns (string memory) {
    return
      string(
        abi.encodePacked(
          '{"trait_type":"',
          traitType,
          '","value":"',
          traitName,
          '"}'
        )
      );
  }
}
