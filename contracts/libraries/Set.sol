// SPDX-License-Identifier: none
pragma solidity ^0.8.17;

/**
 * This is a library for managing a set of keys where the keys are uint16. It's based on the
 * rob-Hitchens/UnorderedKeySet
 *
 * https://github.com/rob-Hitchens/UnorderedKeySet/blob/dd8c423743dc4b47d8c95ba1ccf44778bbf4315b/contracts/HitchensUnorderedKeySet.sol#L34
 */
library Set {
  struct ByInt16 {
    mapping(uint16 => uint) keyPointers;
    uint16[] keyList;
  }

  function insert(ByInt16 storage self, uint16 key) internal {
    require(key != 0x0, "Set(100) - Key cannot be 0x0");
    require(!exists(self, key), "Set(101) - Key already exists in the set.");
    self.keyList.push(key);
    self.keyPointers[key] = self.keyList.length - 1;
  }

  function remove(ByInt16 storage self, uint16 key) internal {
    require(exists(self, key), "Set(102) - Key does not exist in the set.");
    uint16 keyToMove = self.keyList[count(self) - 1];
    uint rowToReplace = self.keyPointers[key];
    self.keyPointers[keyToMove] = rowToReplace;
    self.keyList[rowToReplace] = keyToMove;
    delete self.keyPointers[key];
    self.keyList.pop();
  }

  function count(ByInt16 storage self) internal view returns (uint) {
    return (self.keyList.length);
  }

  function exists(
    ByInt16 storage self,
    uint16 key
  ) internal view returns (bool) {
    if (self.keyList.length == 0) return false;
    return self.keyList[self.keyPointers[key]] == key;
  }

  function keyAtIndex(
    ByInt16 storage self,
    uint index
  ) internal view returns (uint16) {
    return self.keyList[index];
  }

  function nukeSet(ByInt16 storage self) internal {
    delete self.keyList;
  }

  struct ByIntString {
    mapping(string => uint) keyPointers;
    string[] keyList;
  }

  function insert(ByIntString storage self, string memory key) internal {
    require(bytes(key).length > 0, "Set(100) - Key cannot be 0x0");
    require(!exists(self, key), "Set(101) - Key already exists in the set.");
    self.keyList.push(key);
    self.keyPointers[key] = self.keyList.length - 1;
  }

  function remove(ByIntString storage self, string memory key) internal {
    require(exists(self, key), "Set(102) - Key does not exist in the set.");
    string memory keyToMove = self.keyList[count(self) - 1];
    uint rowToReplace = self.keyPointers[key];
    self.keyPointers[keyToMove] = rowToReplace;
    self.keyList[rowToReplace] = keyToMove;
    delete self.keyPointers[key];
    self.keyList.pop();
  }

  function count(ByIntString storage self) internal view returns (uint) {
    return (self.keyList.length);
  }

  function exists(
    ByIntString storage self,
    string memory key
  ) internal view returns (bool) {
    if (self.keyList.length == 0) return false;
    return compare(self.keyList[self.keyPointers[key]], key);
  }

  function keyAtIndex(
    ByIntString storage self,
    uint index
  ) internal view returns (string memory) {
    return self.keyList[index];
  }

  function nukeSet(ByIntString storage self) internal {
    delete self.keyList;
  }

  function compare(
    string memory str1,
    string memory str2
  ) private pure returns (bool) {
    if (bytes(str1).length != bytes(str2).length) {
      return false;
    }
    return
      keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
  }
}
