// SPDX-License-Identifier: none
// NFB Contracts v0.0.2
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/INFTDescriptor.sol";
import "./interfaces/INFTMinter.sol";
import "./interfaces/INFTRepository.sol";

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

  uint256 private nextTokenId = 1;
  address nftDescriptorAddress;
  address nftRepository;

  constructor(address _nftRepository, address _nftDescriptor) ERC721("MYNAME", "MYN") {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(MINTER_ROLE, msg.sender);
    _grantRole(AIRDROP_MANAGER_ROLE, msg.sender);
    
    nftRepository = _nftRepository;
    nftDescriptorAddress = _nftDescriptor;
  }

  /// @dev This is not meant to be a public minting function, but rather a function that can be called by other contracts.
  // This method creates a new randomized NFT for the given series and edition.
  function mint(
    address to,
    uint16 seriesId,
    uint8 editionId
  ) external override onlyRole(MINTER_ROLE) returns (uint256) {
    NFTInstance memory instance = INFTRepository(nftRepository).craeteRandom(
      seriesId,
      editionId
    );
    uint256 tokenId = _mintInstance(to, instance);
    emit Minted(to, seriesId, editionId, tokenId);

    return tokenId;
  }

  /// @dev This is not meant to be a public minting function, but rather a function that can be called by other contracts.
  // This method creates a new airdrop for the given config.
  function airdrop(
    address to,
    uint16 seriesId,
    uint8 editionId,
    bytes32 typeName,
    NFTTrait[] calldata traits
  ) external override onlyRole(AIRDROP_MANAGER_ROLE) returns (uint256) {
    NFTInstance memory instance = INFTRepository(nftRepository).create(
      seriesId,
      editionId,
      typeName,
      traits
    );
    uint256 tokenId = _mintInstance(to, instance);
    emit Airdroped(to, seriesId, editionId, tokenId);

    return tokenId;
  }

  function setNFTDescriptorAddress(
    address _nftDescriptorAddress
  ) public onlyOwner {
    nftDescriptorAddress = _nftDescriptorAddress;
  }

  function tokenURI(
    uint256 tokenId
  ) public view virtual override returns (string memory) {
    string memory baseData = super.tokenURI(tokenId);
    NFTInstance memory instance = abi.decode(bytes(baseData), (NFTInstance));

    return INFTDescriptor(nftDescriptorAddress).tokenURI(tokenId, instance);
  }

  // The following functions are overrides required by Solidity.

  function supportsInterface(
    bytes4 interfaceId
  ) public view override(AccessControl, ERC721) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  // private methods

  // @dev Mint the new instance and increase the token id.
  function _mintInstance(
    address to,
    NFTInstance memory instance
  ) internal onlyMinterOrAirdropManager returns (uint256) {
    bytes memory data = abi.encode(instance);
    nextTokenId++;
    _safeMint(to, nextTokenId, data);

    return nextTokenId;
  }
}
