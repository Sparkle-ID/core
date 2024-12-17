# Sparkle ID Smart Contracts

Welcome to the Sparkle ID smart contracts repository. This project powers a decentralized identity management system on the Hedera Hashgraph network. The contracts implement various facets that enable decentralized identity issuance, management, and verification.

## Deployed Contracts

Below are the key smart contracts deployed on the Hedera Hashgraph network:

| Contract Name                | Contract Address                          | Description                          |
|-----------------------------|----------------------------------------------|--------------------------------------|
| AccessControlFacet           | 0xd482AB70E35bc946a4Ae43d79d4C11257Dfb7c2e | Manages access control mechanisms   |
| DiamondCutFacet              | 0xc3f009AbF560Dc509D58b90a4eA1DED8E3193743 | Facilitates adding/removing facets  |
| DiamondLoupeFacet            | 0x22b4f3bA25aF039c9798546aA3C14aC62C5e62B4 | Provides contract introspection     |
| OwnershipFacet               | 0x3e75CcCb52D0cEb0b6c04ec7129cef00Bcc86348 | Manages contract ownership          |
| CredentialRegistryFacet      | 0xA55e364Ae9EB10b6C62F75bCc052540e9B334aaB | Handles credential registration     |
| DIDRegistryFacet             | 0x08752E11Be68a86CbE3934AF64Ba512389d9a633 | Manages decentralized IDs (DIDs)    |
| SubDIDRegistryFacet          | 0xF9c16972FD50B16459Ed7067Aa44653BC56075B4 | Manages sub-DIDs under main DIDs    |
| DiamondInit                  | 0x441BC42C2acd467aF202687e88cBA93DD9c94B9f | Handles diamond initialization      |
| Diamond                      | 0xda33F5283af4Dc35e99e784e6ac03DC158a95277 | Main diamond proxy contract         |

## Key Features

- **Decentralized ID Management:** Issue, manage, and revoke decentralized identities.
- **Credential Management:** Register, verify, and manage user credentials.
- **Access Control:** Granular permission management.
- **Upgradability:** Modular design using the Diamond Standard (EIP-2535).

## Deployment Details

- **Network:** Hedera Hashgraph Testnet
- **Deployment Nonces:** Contracts were deployed using sequential nonces, ensuring precise order and dependency management.

## Development

To run the project locally:

1. Clone this repository:
   ```bash
   git clone https://github.com/your-repo/sparkle-id.git
   cd sparkle-id
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Run tests:
   ```bash
   npm run test:all
   ```

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contribution

We welcome contributions! Please create an issue or submit a pull request for any feature requests or improvements.

---

For more information, visit [Hedera Hashgraph](https://hedera.com).

