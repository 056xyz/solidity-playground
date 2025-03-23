# Auction House System

A decentralized auction system consisting of an ERC721 token (NFT) and a AuctionHouse contract.

## Installation

1. Install dependencies

```bash
npm install
```

2. Create `.env` file

```bash
SEPOLIA_RPC_URL=your_sepolia_rpc_url
PRIVATE_KEY=your_private_key
ETHERSCAN_API_KEY=your_etherscan_api_key
```

## Testing

Run the test suite:

```bash
npx hardhat test
```

Run test coverage:

```bash
npx hardhat coverage
```

## Deployment

Deploy both contracts to Sepolia:

```bash
npx hardhat deploy --owner <nft-owner-address> --network sepolia
```

### Deployment Parameters

- `owner`: address of the NFT contract owner

## Contract Verification

Contracts are automatically verified on Etherscan when deployed to Sepolia.

