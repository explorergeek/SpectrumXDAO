//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Base64} from "./libraries/Base64.sol";

contract SpectrumX is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIds;

    string public constant NAME = "SpectrumX";
    string public constant SYMBOL = "SPEC";
    uint8 public constant MAX_PER_USER = 20;
    uint16 public constant MAX_TOKENS = 2500;
    uint256 public constant TOKEN_PRICE = 70000000000000000; //0.07ETH

    string public baseTokenURI = "ipfs://";

    string svgBase =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    //Structs
    struct RenderToken {
        uint256 id;
        string uri;
    }

    //mappings
    mapping(uint256 => string) _tokenURIs;

    constructor() ERC721(NAME, SYMBOL) {
        setBaseURI(baseTokenURI);
        console.log("Testing test deploy", NAME, SYMBOL);
    }

    //events
    event NewSpexctrumXNFTMinted(address sender, uint256 tokenId);

    //Verifies the user is not trying to mint too many NFTs
    modifier maxMint(uint256 _amountOfTokens) {
        require(
            balanceOf(msg.sender) + _amountOfTokens <= MAX_PER_USER,
            "You already have maximum number of tokens allowed per wallet"
        );
        _;
    }
    //Verifies there is enough Eth in the account to be able to mint the NFT
    modifier isEnoughEth(uint256 _amountOfTokens) {
        require(
            _amountOfTokens * TOKEN_PRICE == msg.value,
            "Incorrect ETH value"
        );
        _;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        _tokenURIs[tokenId] = _tokenURI;
    }

    function getAllTokens() public view returns (RenderToken[] memory) {
        uint256 latestId = _tokenIds.current();
        uint256 counter = 0;
        RenderToken[] memory currentTokens = new RenderToken[](latestId);
        for (uint256 index = 0; index < currentTokens.length; index++) {
            if (_exists(counter)) {
                string memory uri = tokenURI(counter);
                currentTokens[counter] = RenderToken(counter, uri);
            }
            counter++;
        }
        return currentTokens;
    }

    /**
     * @dev Returns an URI for a given token ID
     */
    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(_tokenId));
        string memory _tokenURI = _tokenURIs[_tokenId];
        return _tokenURI;
        //return Strings.strConcat(baseTokenURI(), Strings.uint2str(_tokenId));
    }

    function newMint() external {
        uint256 newTokenId = _tokenIds.current() + 1;
        require(newTokenId <= MAX_TOKENS, "No available tokens to mint");
        string memory nftSVG = string(
            abi.encodePacked(
                svgBase,
                "SpectrumX DAO Membership",
                "</text></svg>"
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "SpectrumX DAO Membership Pass", "description": "Allows access to SpectrumX DAO including the opportunity to take part in revolutionizing mentorship within web3.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(nftSVG)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n-----");
        console.log(finalTokenUri);
        console.log("-----\n");

        _safeMint(msg.sender, newTokenId);

        setTokenURI(newTokenId, finalTokenUri);
        _tokenIds.increment();

        console.log("An NFT w/ ID %s has been minted to %s", newTokenId, msg.sender);

        emit NewSpexctrumXNFTMinted(msg.sender, newTokenId);
    }

    /**************ADMIN BASE FUNCTIONS *************/
    function _baseURI() internal view override(ERC721) returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function getTokensMinted() public view returns (uint256) {
        return _tokenIds.current() + 1;
    }

    function withdrawAll() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }
}
