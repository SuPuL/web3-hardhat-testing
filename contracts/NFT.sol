// SPDX-License-Identifier: none
// NFB Contracts v0.0.2
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/INFTDescriptor.sol";
import "./interfaces/INFTRepository.sol";
import "./interfaces/INFTMinter.sol";
import "hardhat/console.sol";

/**
 * @dev Nfts should be split this in a static and a dynamic part.
 * The static part that is the same for most types can be stored in one mapping and the individual part in another mapping.
 */
contract NFT is Ownable, AccessControl, ERC721, INFTMinter {
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 public constant AIRDROP_MANAGER_ROLE =
    keccak256("AIRDROP_MANAGER_ROLE");

  modifier onlyMinterOrAirdropManager() {
    require(
      hasRole(MINTER_ROLE, msg.sender) ||
        hasRole(AIRDROP_MANAGER_ROLE, msg.sender),
      "NFT: caller does not have the required role"
    );
    _;
  }

  mapping(uint256 => bytes) private storageInfos;

  uint256 private nextTokenId = 0;
  INFTDescriptor nftDescriptor;
  INFTRepository nftRepository;

  constructor(
    string memory _name,
    string memory _symbol,
    INFTRepository _nftRepository,
    INFTDescriptor _nftDescriptor
  ) ERC721(_name, _symbol) {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(MINTER_ROLE, msg.sender);
    _grantRole(AIRDROP_MANAGER_ROLE, msg.sender);

    nftRepository = _nftRepository;
    nftDescriptor = _nftDescriptor;
  }

  /// @dev This is not meant to be a public minting function, but rather a function that can be called by other contracts.
  // This method creates a new randomized NFT for the given series and edition.
  function mint(
    address to,
    uint16 seriesId,
    uint8 editionId
  ) external override onlyRole(MINTER_ROLE) returns (uint256) {
    NFTStorageInfo memory storageInfo = nftRepository.craeteRandom(
      seriesId,
      editionId
    );
    uint256 tokenId = _mintStorageInfo(to, storageInfo);
    emit Minted(to, seriesId, editionId, tokenId);

    return tokenId;
  }

  /// @dev This is not meant to be a public minting function, but rather a function that can be called by other contracts.
  // This method creates a new airdrop for the given config.
  function airdrop(
    address to,
    uint16 seriesId,
    uint8 editionId,
    uint16 typeId,
    NFTAttributeValue[] calldata values
  ) external override onlyRole(AIRDROP_MANAGER_ROLE) returns (uint256) {
    NFTStorageInfo memory storageInfo = nftRepository.create(
      seriesId,
      editionId,
      typeId,
      values
    );
    uint256 tokenId = _mintStorageInfo(to, storageInfo);
    emit Airdroped(to, seriesId, editionId, tokenId);
    return tokenId;
  }

  function setNFTDescriptorAddress(
    address _nftDescriptorAddress
  ) public onlyOwner {
    nftDescriptor = INFTDescriptor(_nftDescriptorAddress);
  }

  function tokenURI(
    uint256 tokenId
  ) public view virtual override returns (string memory) {
    require(storageInfos[tokenId].length > 0, "NFT: token id not found");
    bytes memory baseData = storageInfos[tokenId];
    NFTStorageInfo memory storageInfo = abi.decode(baseData, (NFTStorageInfo));
    NFTInstance memory instance = nftRepository.enrich(tokenId, storageInfo);

    return nftDescriptor.tokenURI(tokenId, instance);
  }

  // The following functions are overrides required by Solidity.

  function supportsInterface(
    bytes4 interfaceId
  ) public view override(AccessControl, ERC721) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  // private methods

  /**
   *  @dev Mint the new storageInfo and increase the token id.
   */
  function _mintStorageInfo(
    address to,
    NFTStorageInfo memory storageInfo
  ) internal onlyMinterOrAirdropManager returns (uint256) {
    nextTokenId++;
    _safeMint(to, nextTokenId);
    storageInfos[nextTokenId] = abi.encode(storageInfo);

    return nextTokenId;
  }
}
