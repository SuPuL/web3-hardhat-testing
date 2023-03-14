// SPDX-License-Identifier: none
// NFB Contracts v0.0.2
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./libraries/NFTSchema.sol";
import "./libraries/Traits.sol";
import "./interfaces/INFTDescriptor.sol";
import "./interfaces/INFTSchemaRepository.sol";

/**
 * @notice add access control
 */
contract NFTDescriptor is INFTDescriptor {
  using Strings for uint16;
  INFTSchemaRepository public repository;

  constructor(address _repository) {
    repository = INFTSchemaRepository(_repository);
  }

  function tokenURI(
    uint256 tokenId,
    NFTInstance calldata instance
  ) external view override returns (string memory) {
    return _generateURI(tokenId, instance);
  }

  function _generateURI(
    uint256 tokenId,
    NFTInstance calldata instance
  ) private view returns (string memory) {
    NFTDefinition memory definition = repository.getTypeDefintion(
      instance.seriesId,
      instance.editionId,
      instance.typeName
    );

    Traits.Trait[] memory traits = _toTraits(instance, definition);

    // @todo generate code and use asset proxy or use ipfs resolving per chainlink oracles
    string memory imageURI = string(
      abi.encodePacked("https://foo.bar/", tokenId, ".png")
    );

    string memory metadata = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            "{",
            '"id":"',
            tokenId,
            '","name":"',
            instance.typeName,
            '","description":"',
            definition.nftType.description,
            '","image":"',
            imageURI,
            '",',
            '"attributes":',
            Traits.encode(traits),
            "}"
          )
        )
      )
    );

    return string(abi.encodePacked("data:application/json;base64,", metadata));
  }

  function _toTraits(
    NFTInstance calldata instance,
    NFTDefinition memory definition // why do I have to use memory here? And why cant i use calldata?
  ) private pure returns (Traits.Trait[] memory) {
    uint8 extraTraits = 5;

    Traits.Trait[] memory traits = new Traits.Trait[](
      instance.traits.length + extraTraits
    );

    traits[0] = Traits.get("Series", definition.edition.seriesName);
    traits[1] = Traits.get("Series ID", definition.edition.seriesId, "number");
    traits[2] = Traits.get("Edition", definition.edition.editionName);
    traits[3] = Traits.get(
      "Edition ID",
      definition.edition.editionId,
      "number"
    );
    traits[4] = Traits.get("Type", instance.typeName);

    NFTType memory nftType = definition.nftType;
    for (uint8 i = extraTraits; i < instance.traits.length; i++) {
      NFTTrait memory nftTrait = instance.traits[i];
      bytes32 displayType = _findDisplayType(
        nftType.traitTypes,
        nftTrait.traitType
      );

      traits[i] = Traits.get(
        nftTrait.traitType,
        nftTrait.traitName,
        displayType
      );
    }

    return traits;
  }

  function _findDisplayType(
    NFTTraitType[] memory traitTypes, // why do I have to use memory here? And why cant i use calldata?
    bytes32 traitType
  ) public pure returns (bytes32) {
    for (uint256 i = 0; i < traitTypes.length; i++) {
      if (traitTypes[i].traitType == traitType) {
        return traitTypes[i].displayType;
      }
    }

    return 0;
  }
}
