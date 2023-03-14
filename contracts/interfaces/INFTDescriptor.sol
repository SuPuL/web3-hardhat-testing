// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "../libraries/NFTInstance.sol";

interface INFTDescriptor {
  function tokenURI(
    uint256 tokenId,
    NFTInstance calldata instance
  ) external view returns (string memory);
}
