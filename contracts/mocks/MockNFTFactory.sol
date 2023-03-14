// SPDX-License-Identifier: none
// NFB Contracts v0.0.2
pragma solidity ^0.8.17;

import "../interfaces/INFTFactory.sol";

contract MockNFTFactory is INFTFactory {
    function craeteRandom() external view returns (NFTInstance memory) {

    }

  function create(
    bytes32 typeName,
    NFTTrait[] calldata traits
  ) external pure returns (NFTInstance memory) {
    return NFTInstance({
        seriesId: 0,
        editionId: 0,
        typeName: typeName,
        traits: traits
    });
  }
}