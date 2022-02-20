//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SpectrumX is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIds;

    string public constant NAME = "SpectrumX";
    string public constant SYMBOL = "SPEC";
    uint8 public constant MAX_PER_USER = 20;
    uint16 public constant MAX_TOKENS = 2500;
    uint256 public constant TOKEN_PRICE = 70000000000000000; //0.07ETH

    string public baseTokenURI = "ipfs://";

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

    function mint(string memory uri) external {
        uint256 newTokenId = _tokenIds.current() + 1;
        require(newTokenId <= MAX_TOKENS, "No available tokens to mint");
        _safeMint(msg.sender, newTokenId);
        setTokenURI(newTokenId, uri);
        _tokenIds.increment();
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
