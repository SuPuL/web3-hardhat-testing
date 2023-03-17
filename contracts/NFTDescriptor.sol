// SPDX-License-Identifier: none
// NFB Contracts v0.0.2
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./libraries/JSON.sol";
import "./libraries/Types.sol";
import "./interfaces/INFTDescriptor.sol";

struct JSONProp {
  string key;
  string value;
}

/**
 * @notice add access control
 */
contract NFTDescriptor is Ownable, AccessControl, INFTDescriptor {
  using Strings for uint16;
  using Strings for uint256;

  bytes32 public constant DESCRIPTOR_MANAGER_ROLE =
    keccak256("DESCRIPTOR_MANAGER_ROLE");

  string baseExternalUrl;
  string imageBaseUrl;
  string assetBaseUrl;

  constructor(
    string memory _baseExternalUrl,
    string memory _imageBaseUrl,
    string memory _assetBaseUrl
  ) {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(DESCRIPTOR_MANAGER_ROLE, msg.sender);

    baseExternalUrl = _baseExternalUrl;
    imageBaseUrl = _imageBaseUrl;
    assetBaseUrl = _assetBaseUrl;
  }

  // create setter functions for base urls secured by a manager role modifier
  function setBaseExternalUrl(
    string memory _baseExternalUrl
  ) external onlyRole(DESCRIPTOR_MANAGER_ROLE) {
    baseExternalUrl = _baseExternalUrl;
  }

  function setImageBaseUrl(
    string memory _imageBaseUrl
  ) external onlyRole(DESCRIPTOR_MANAGER_ROLE) {
    imageBaseUrl = _imageBaseUrl;
  }

  function setAssetBaseUrl(
    string memory _assetBaseUrl
  ) external onlyRole(DESCRIPTOR_MANAGER_ROLE) {
    assetBaseUrl = _assetBaseUrl;
  }

  function tokenURI(
    uint256 tokenId,
    NFTInstance calldata instance
  ) external view override returns (string memory) {
    return _generateURI(tokenId, instance.nftType, instance.traits);
  }

  function _generateURI(
    uint256 tokenId,
    NFTType calldata nftType,
    NFTTrait[] calldata traits
  ) private view returns (string memory) {
    require(tokenId > 0, "NFT: invalid token id");
    require(bytes(nftType.name).length > 0, "NFT: invalid name");

    string memory image = string.concat(nftType.image, imageBaseUrl);
    string memory animation_url = string.concat(
      nftType.animation,
      assetBaseUrl
    );
    string memory external_url = string.concat(
      baseExternalUrl,
      tokenId.toString()
    );

    string[] memory props = new string[](7);
    props[0] = JSON.prop("id", tokenId.toString());
    props[1] = JSON.prop("name", nftType.name);
    props[2] = JSON.prop("description", nftType.description);
    props[3] = JSON.prop("image", image);
    props[4] = JSON.prop("animation_url", animation_url);
    props[5] = JSON.prop("external_url", external_url);
    props[6] = JSON.prop("attributes", JSON.encode(traits));

    string memory json = JSON.obj(props);
    // string memory metadata = Base64.encode(json);
    // lets check if strings are per default base64
    string memory metadata = json;

    return string(abi.encodePacked("data:application/json;base64,", metadata));
  }
}
