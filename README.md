# Web3 ERC 721 playground

This project is just a playground to get familiar with different aspects of ERC-721 contracts.

# TODO

- Configuration contracts
  - ✅ add edition hashing -> series id + edition id
  - ✅ add type hashing -> series id + edition id + type id
  - ✅ Add Edition config only
  - ✅ Add Types config per edition
  - ✅ Add lock edition (no more types can be added)
  - Add stop editions (no more NFTs can be generated)
  - Handle schema changes? Versions?
- ✅ Asset handling -> is configured in the schema
  - ✅ contract based, get assets per Type hash
  - ✅ asset configuration per type hash (IPFS mapping for image, gif and/or video to type)
  - do we want Gifs and PFPs?
- NFT store
  - ✅ only store NFT individual data per token
  - store static data per type
  - optimize storage handling for statics
  - ✅ add birthday
- ✅ NFT descriptor tokenUri generation
  - ✅ get assets and static data from type store
  - ✅ merge with instance data
- NFB support
  - "random create can only be done with NFB" <- configureable
  - mint, open
- Add Basic NFT Repository
  - add random generation
  - ✅ add airdrop generation
- Add Example utility contract to burn something and create something new
- Add Helper for FE
  - get all schemas
- Create some account abstraction example (so that a user can have multiple wallets with n NFTs)
- What about gifs or other assets per NFT as extra info?
- Tests, Tests, Tests...

## Optimizations

- flatten libs?
- Merge Descriptor and Schema? Or other contracts?
- Store NFT data not in ERC contract?
- bytes instead of stings?
