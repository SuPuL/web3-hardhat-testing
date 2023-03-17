// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "../libraries/Schema.sol";
import "../libraries/Types.sol";

interface INFTMinter {
  event Minted(address to, uint16 seriesId, uint8 editionId, uint256 tokenId);
  event Airdroped(
    address to,
    uint16 seriesId,
    uint8 editionId,
    uint256 tokenId
  );

  function mint(
    address to,
    uint16 seriesId,
    uint8 editionId
  ) external returns (uint256 tokenId);

  function airdrop(
    address to,
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    NFTAttributeValue[] calldata values
  ) external returns (uint256 tokenId);
}
