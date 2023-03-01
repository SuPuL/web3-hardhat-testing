// SPDX-License-Identifier: none
// NFB Contracts v0.0.2
pragma solidity ^0.8.9;

import "./interfaces/INFTDescriptor.sol";

contract NFTDescriptor is INFTDescriptor {
  function tokenURI(
    NFTInstance calldata instance
  ) external view override returns (string memory) {
    return "https://nftbase.io";
  }
}
