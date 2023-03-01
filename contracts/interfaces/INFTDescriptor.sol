// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "../libraries/NFTInstance.sol";

interface INFTDescriptor {
  function tokenURI(
    NFTInstance calldata instance
  ) external view returns (string memory);
}
