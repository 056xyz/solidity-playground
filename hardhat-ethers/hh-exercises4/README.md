# Token Crowdsale System

A decentralized token sale system consisting of an ERC20 token (CustomToken) and a Crowdsale contract.

## Contracts

### CustomToken (MTK)

- ERC20 token with 8 decimals
- Initial supply: 50,000 MTK
- Symbol: MTK
- Name: Crowd

### Crowdsale

- Time-bound sale period (minimum 1 week)
- Configurable token price (tokens per ETH)
- Automatic token distribution
- ETH collection with configurable fee receiver
- Owner-controlled finalization

## Installation

1. Clone the repository

```bash
git clone <repository-url>
cd 13-exercise
```

2. Install dependencies

```bash
npm install
```

3. Create `.env` file

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
--network sepolia \
--start-offset 3600 \
--duration 604800 \
--price 50 \
--tokens-for-sale 50000 \
--fee-receiver 0xYourFeeReceiverAddress
```

### Deployment Parameters

- `start-offset`: Sale start delay in seconds (default: 1000)
- `duration`: Sale duration in seconds (default: 1 week)
- `price`: Tokens per ETH (default: 50)
- `tokens-for-sale`: Number of tokens for sale (default: 50000)
- `fee-receiver`: ETH recipient address (default: deployer)

## Buying Tokens

Use the buy task to purchase tokens:

```
npx hardhat buy \
--network sepolia \
--crowdsale 0xYourCrowdsaleAddress \
--amount 1.5 \
--receiver 0xReceiverAddress
```

## Contract Verification

Contracts are automatically verified on Etherscan when deployed to Sepolia.
