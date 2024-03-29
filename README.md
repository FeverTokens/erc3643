# Diamond Standard Implementation for Ethereum Smart Contracts

## Overview

This project provides a framework for creating upgradeable smart contracts on the Ethereum blockchain using the Diamond Standard. It allows developers to create modular and upgradeable smart contracts by separating the logic into facets that can be added or removed without changing the main contract.

## Why This Project Exists

The project exists to solve the problem of upgradability in Ethereum smart contracts. By implementing the Diamond Standard, developers can easily upgrade their smart contracts without disrupting the existing functionality or losing state data.

## Main Technologies and Frameworks

- **Solidity**: The smart contracts are written in Solidity, the programming language for Ethereum smart contracts.
- **Hardhat**: The project uses Hardhat as the development environment for Ethereum smart contracts.
- **TypeScript**: Some of the scripts and configurations are written in TypeScript.
- **pnpm**: The project uses pnpm as the package manager.
- **Ethereum**: The project is built for the Ethereum blockchain.

## Codebase Organization

- **contracts**: Contains the main smart contracts, including facets for different functionalities like DiamondCut, DiamondLoupe, ERC20, ERC3643, Ownership, and test contracts.
- **interfaces**: Contains the interfaces used in the smart contracts.
- **libraries**: Contains the libraries used in the project.
- **upgradeInitializers**: Contains the initialization logic for the Diamond contract.
- **scripts**: Contains deployment scripts for the smart contracts.
- **test**: Contains test scripts for testing the smart contracts.
- **hardhat.config.ts**: Contains the configuration for the Hardhat development environment.
- **package.json**: Contains the project dependencies.
- **pnpm-lock.yaml**: Contains the lock file for pnpm.
- **README.md**: This file.
- **tsconfig.json**: Contains the TypeScript configuration for the project.

## Getting Started

### Prerequisites

- Node.js
- pnpm
- Hardhat

### Installation

1. Clone the repository

2. Navigate to the project directory:

```bash
cd yourrepository
```

3. Install dependencies:

```
pnpm install
```

### Running the Project

- To compile the smart contracts:

```
pnpm compile
```

- To deploy the smart contracts:

```
pnpm deploy:local
```

- To test the smart contracts:

```
pnpm hardhat test
```

## Contributing

Contributions are welcome! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License
