# Staking Pool

A basic staking mechanism protocol.

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
********
Deploy both contracts to Sepolia:

```bash
npx hardhat deploy --network sepolia
```

## Contract Verification

Contracts are automatically verified on Etherscan when deployed to Sepolia.

### Verified Contracts (Sepolia)

- StakingToken Etherscan: [0x2076F2B8A35eFe234704069F66c0668A8acf6CAf] https://sepolia.etherscan.io/address/0x2076F2B8A35eFe234704069F66c0668A8acf6CAf#code
- StakingToken Sourcify: https://repo.sourcify.dev/contracts/full_match/11155111/0x2076F2B8A35eFe234704069F66c0668A8acf6CAf/
- StakingPool Etherscan: [0xB2fD836D3607958176fD8579203Dab28b4F46Dad] https://sepolia.etherscan.io/address/0xB2fD836D3607958176fD8579203Dab28b4F46Dad#code