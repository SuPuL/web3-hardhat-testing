// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "../libraries/NFTInstance.sol";

interface INFTStorage {
  function getNFT(uint256 tokenId) external view returns (NFTInstance memory);

  function setNFT(uint256 tokenId, NFTInstance memory) external;
}
