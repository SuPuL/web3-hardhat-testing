// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "../libraries/NFTInstance.sol";

interface INFTStorage {
  function getNFT(uint256 tokenId) external view returns (NFTInstance calldata);

  function setNFT(uint256 tokenId, NFTInstance calldata) external;
}
