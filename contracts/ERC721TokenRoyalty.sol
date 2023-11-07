// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ERC721TokenRoyalty is ERC721Royalty, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    address immutable signer;
    mapping(uint256 => string) tokenURIs;
    mapping(address => mapping(string => bool)) public ownerHaveURI;
    uint96 immutable feeNumerator;
    mapping(address => uint256) public currentCount;

    event SafeMintSigner(address sender, uint256 ID);

    constructor(
        string memory _name, 
        string memory _symbol, 
        address _signer,
        uint96 fee
    ) ERC721(_name, _symbol) {
        signer = _signer;
        feeNumerator = fee;
    }

    function safeMint(address to, string memory uri) external onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        tokenURIs[tokenId] = uri;
        _setTokenRoyalty(tokenId, to, feeNumerator);
    }

    function safeMintSigner(
        bytes32 r,
        uint8 v,
        bytes32 s,
        string memory uri
    ) external {
        require(check(r, v, s, uri, currentCount[msg.sender]), 'ERC721Mintable: Wrong signature');
        require(!ownerHaveURI[msg.sender][uri], 'ERC721Mintable: Already have');
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        tokenURIs[tokenId] = uri;
        ownerHaveURI[msg.sender][uri] = true;
        _setTokenRoyalty(tokenId, msg.sender, feeNumerator);
        currentCount[msg.sender] += 1;
        emit SafeMintSigner(msg.sender, tokenId);
    }

    function tokenURI(uint256 tokenId) public view override returns(string memory) {
        return tokenURIs[tokenId];
    }

    function check(
        bytes32 r,
        uint8 v,
        bytes32 s,
        string memory uri,
        uint256 count
    ) private view returns (bool) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                uri,
                msg.sender,
                address(this),
                count
            )
        );
        return
            signer ==
            ecrecover(
                keccak256(
                    abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
                ),
                v,
                r,
                s
            );
    }

}
