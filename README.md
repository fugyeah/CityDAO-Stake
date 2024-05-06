### Overview

The `CitizenStaking` smart contract is designed to facilitate a seamless transition for CITYDAO members into a new governance system by allowing them to stake their existing CITYDAO ERC1155 tokens in exchange for new ERC721 tokens. These new tokens represent voting shares and governance rights in the new system. The contract is built on Ethereum and utilizes Solidity 0.8.0.

### Features

- **Token Staking**: Members can stake three types of CITYDAO ERC1155 tokens: Citizen, Founding, and First tokens. These are identified by their token IDs: 42, 69, and 7, respectively.
- **ERC721 Token Issuance**: For every staking transaction, the contract issues an ERC721 token to the staker. This token represents the governance rights proportionate to the amount and type of tokens staked.
- **On-Chain SVG Token Visualization**: Each ERC721 token issued contains a unique SVG image encoded in its metadata. This image visually represents the amounts of each type of ERC1155 token staked, enhancing transparency and engagement for token holders.
- **Batch Transfer Optimization**: The contract employs batch transfers for staking, enhancing efficiency and reducing transaction costs.
- **Ownership and Treasury Management**: The contract is owned by the deployer initially, with the capability to transfer ownership and update the treasury address, which is designed to support multisig wallet integration for decentralized governance.

### Functions

- **`stakeTokens(uint256 _citizenAmount, uint256 _foundingAmount, uint256 _firstAmount)`**: Allows users to stake their ERC1155 tokens in specified amounts. Transfers these tokens from the user to the contract and mints a new ERC721 token for the user.
- **`setTreasury(address _newTreasury)`**: Allows the owner to update the treasury address, ensuring flexibility in financial and governance arrangements.
- **`setTokenSVG(uint256 tokenId, uint256 numRegular, uint256 numFounding, uint256 numFirst)`**: Internal function that generates and sets an SVG image as the token URI based on the staked amounts.
- **`generateSVGImage(uint256 numRegular, uint256 numFounding, uint256 numFirst)`**: Generates an SVG image string representing the staked tokens.
- **`formatTokenURI(string memory imageURI)`**: Encodes the SVG string in base64 and formats it as a data URI for inclusion in the ERC721 token metadata.

### Events

- **`TokensStaked(address indexed user, uint256 indexed tokenId, uint256 citizenAmount, uint256 foundingAmount, uint256 firstAmount)`**: Emitted after a successful staking operation, capturing details about the stake and the new token issued.

### Deployment and Configuration

- **Initial Setup**: Deploy the contract with the CITYDAO ERC1155 contract address as a parameter.
- **Treasury Configuration**: Initially set to the contract deployer, the treasury address can be updated to a multisig wallet or another governance-controlled wallet as required.

### Security Considerations

- **Reentrancy Guard**: The contract uses the OpenZeppelin `ReentrancyGuard` to prevent re-entrant attacks in staking function.
- **Access Control**: Functions that can alter the state significantly (like `setTreasury`) are protected by the `onlyOwner` modifier to ensure that only authorized addresses can execute them.
