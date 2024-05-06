// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract CitizenStaking is ERC721URIStorage, Ownable, ReentrancyGuard {
    using Strings for uint256;

    IERC1155 public cityDaoTokens;
    address public treasury;

    // Constants for the token IDs
    uint256 public constant CITIZEN_NFT_ID = 42;
    uint256 public constant FOUNDING_NFT_ID = 69;
    uint256 public constant FIRST_NFT_ID = 7;

    // Mapping from ERC721 token ID to a structure that contains the staked amounts for each token type
    struct Stakes {
        uint256 citizenAmount;
        uint256 foundingAmount;
        uint256 firstAmount;
    }

    mapping(uint256 => Stakes) public tokenStakes;

    // Events
    event TokensStaked(address indexed user, uint256 indexed tokenId, uint256 citizenAmount, uint256 foundingAmount, uint256 firstAmount);

    constructor() ERC721("CityDAO Governance Token", "CDGT") {
        cityDaoTokens = IERC1155(0x7EeF591A6CC0403b9652E98E88476fe1bF31dDeb);
        treasury = msg.sender;  // Initially set to the contract deployer
    }

    function stakeTokens(uint256 _citizenAmount, uint256 _foundingAmount, uint256 _firstAmount) external nonReentrant {
        // Transfer tokens from the user to this contract
        cityDaoTokens.safeBatchTransferFrom(msg.sender, address(this), 
            [CITIZEN_NFT_ID, FOUNDING_NFT_ID, FIRST_NFT_ID], 
            [_citizenAmount, _foundingAmount, _firstAmount], "");

        uint256 newTokenId = totalSupply() + 1;
        _mint(msg.sender, newTokenId);
        tokenStakes[newTokenId] = Stakes(_citizenAmount, _foundingAmount, _firstAmount);

        // Set the token URI to the SVG image representing the staked amounts
        setTokenSVG(newTokenId, _citizenAmount, _foundingAmount, _firstAmount);

        emit TokensStaked(msg.sender, newTokenId, _citizenAmount, _foundingAmount, _firstAmount);
    }

    function setTreasury(address _newTreasury) external onlyOwner {
        require(_newTreasury != address(0), "Invalid treasury address");
        treasury = _newTreasury;
    }

    function setTokenSVG(uint256 tokenId, uint256 numRegular, uint256 numFounding, uint256 numFirst) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not owner nor approved");
        string memory imageURI = generateSVGImage(numRegular, numFounding, numFirst);
        _setTokenURI(tokenId, formatTokenURI(imageURI));
    }

    function generateSVGImage(uint256 numRegular, uint256 numFounding, uint256 numFirst) internal pure returns (string memory) {
        // Simplified SVG generation for efficiency
        return string(abi.encodePacked(
            '<svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">',
            '<rect fill="#DDD" width="100%" height="100%"/>',
            '<text x="10" y="20" font-family="Arial" font-size="12">Regular:', numRegular.toString(), '</text>',
            '<text x="10" y="40" font-family="Arial" font-size="12">Founding:', numFounding.toString(), '</text>',
            '<text x="10" y="60" font-family="Arial" font-size="12">First:', numFirst.toString(), '</text>',
            '</svg>'
        ));
    }

    function formatTokenURI(string memory imageURI) private pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(imageURI));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, IERC165) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
