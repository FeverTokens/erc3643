# ERC-3643 Package-Oriented Implementation

## Overview

This project provides a modular implementation of the **ERC-3643 T-REX Token Standard** using the **FeverTokens Package-Oriented Framework**. ERC-3643 is an institutional-grade security token standard that enables compliant transfer of permissioned tokens through automated on-chain validation systems and identity management.

The implementation follows a modular architecture, allowing for upgradeable and composable smart contracts that maintain compliance with securities regulations while providing flexibility for various institutional use cases.

## Why This Project Exists

This project addresses the critical need for compliant security token infrastructure in the blockchain space. By implementing ERC-3643 using a modular package-oriented approach, it provides:

- **Regulatory Compliance**: Automated enforcement of securities laws and transfer restrictions
- **Identity Management**: On-chain identity verification with trusted claim issuers
- **Institutional Features**: Token freezing, pausing, forced transfers, and recovery mechanisms
- **Modularity**: Clean separation of concerns through the FeverTokens Package-Oriented Framework
- **Upgradability**: Diamond Standard compatibility for future enhancements

## Main Technologies and Frameworks

- **ERC-3643 T-REX Standard**: Implements the complete T-REX token standard for regulated securities
- **FeverTokens Package-Oriented Framework**: Modular architecture following Diamond Standard principles
- **Diamond Standard (EIP-2535)**: Upgradeable smart contract architecture with facet-based modularity
- **Solidity ^0.8.26**: Smart contracts written in the latest Solidity version
- **Hardhat**: Development environment for Ethereum smart contracts
- **TypeScript**: Strongly-typed deployment and test scripts
- **pnpm**: Fast, disk-space efficient package manager

## ERC-3643 Package Architecture

This implementation follows the **FeverTokens Package-Oriented Framework**, where each component is structured as a self-contained package with five distinct files:

### Core ERC-3643 Packages

- **`contracts/erc3643/Token/`**: Main ERC-3643 token implementation with compliant transfers
- **`contracts/erc3643/IdentityRegistry/`**: On-chain identity management and verification system
- **`contracts/erc3643/Compliance/`**: Transfer compliance rules and restrictions engine
- **`contracts/erc3643/TrustedIssuersRegistry/`**: Management of trusted claim issuers
- **`contracts/erc3643/ClaimTopicsRegistry/`**: Required claim topics for token holders
- **`contracts/erc3643/AgentManagement/`**: Agent role management for administrative functions

### Package Structure

Each package follows the standard 5-component structure:

- `IPackageInternal.sol` - Internal interface (events, structs, enums)
- `IPackage.sol` - External interface (public functions)
- `PackageStorage.sol` - Diamond storage pattern with ERC-7201 slots
- `PackageInternal.sol` - Internal logic implementation
- `Package.sol` - External contract entry point

### Additional Directories

- **`scripts/`**: Deployment and management scripts
- **`test/`**: Comprehensive test suites for all packages
- **`hardhat.config.ts`**: Hardhat development environment configuration
- **`package-guidelines.md`**: FeverTokens Package-Oriented Framework specification
- **`erc3643-guidelines.md`**: Complete ERC-3643 standard specification

## ERC-3643 Features

This implementation provides all required ERC-3643 functionality:

### Core Features

- **✅ ERC-20 Compatibility**: Full backward compatibility with ERC-20 standard
- **✅ Permissioned Transfers**: All transfers validated through compliance and identity systems
- **✅ On-chain Identity Management**: Integration with on-chain identity verification
- **✅ Compliance Rules Engine**: Configurable transfer restrictions and investor limits
- **✅ Token Recovery System**: Secure recovery mechanism for lost private keys

### Administrative Features

- **✅ Agent Role Management**: Multi-level access control with owner and agent roles
- **✅ Token Pausing**: Emergency pause functionality for the entire token
- **✅ Address Freezing**: Individual wallet freeze/unfreeze capabilities
- **✅ Partial Token Freezing**: Freeze specific amounts within wallets
- **✅ Forced Transfers**: Agent-initiated transfers for compliance purposes

### Batch Operations

- **✅ Batch Transfers**: Gas-efficient multiple transfers in single transaction
- **✅ Batch Minting/Burning**: Bulk token issuance and destruction
- **✅ Batch Freezing**: Multiple address freeze operations
- **✅ Batch Identity Management**: Bulk identity registration and updates

### Compliance Integration

- **✅ Identity Verification**: Automatic verification of transfer participants
- **✅ Claim Validation**: Verification against trusted issuers and required topics
- **✅ Transfer Pre-validation**: `canTransfer()` function for pre-checking compliance
- **✅ Modular Compliance**: Extensible compliance rule system

## Getting Started

### Prerequisites

- Node.js (v16 or higher)
- pnpm package manager
- Hardhat development environment
- Basic understanding of ERC-3643 standard and security tokens

### Installation

1. Clone the repository:

```bash
git clone https://github.com/FeverTokens/erc3643.git
cd erc3643
```

2. Install dependencies:

```bash
pnpm install
```

3. Compile the smart contracts:

```bash
pnpm compile
```

### Development Commands

```bash
# Compile all contracts
pnpm compile

# Run comprehensive test suite
pnpm test:diamond
pnpm test:packages

# Deploy to local network
pnpm deploy:local

# Run linting and formatting
pnpm lint
pnpm lint:fix
```

### Package Guidelines

This project strictly follows the **FeverTokens Package-Oriented Framework**. Before contributing:

1. Read `package-guidelines.md` for architecture principles
2. Review `erc3643-guidelines.md` for ERC-3643 compliance requirements
3. Follow the 5-component package structure for any new packages
4. Ensure proper Diamond storage patterns and access control

## Contributing

Contributions are welcome! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License
