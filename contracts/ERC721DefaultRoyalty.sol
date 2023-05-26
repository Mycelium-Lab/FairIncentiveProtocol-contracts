// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ERC721DefaultRoyalty is ERC721Royalty, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    address immutable signer;
    bool signerAllowance;
    mapping(uint256 => string) tokenURIs;
    mapping(address => mapping(string => bool)) public ownerHaveURI;

    event SafeMintSigner(address sender, uint256 ID);

    constructor(
        string memory _name, 
        string memory _symbol, 
        address _signer,
        address royaltyFeeCollector,
        uint96 fee
    ) ERC721(_name, _symbol) {
        signer = _signer;
        signerAllowance = true;
        _setDefaultRoyalty(royaltyFeeCollector, fee);
    }

    function safeMint(address to, string memory uri) external onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        tokenURIs[tokenId] = uri;
    }

    function changeSignerAllowance(bool _signerAllowance) external onlyOwner {
        signerAllowance = _signerAllowance;
    }

    function safeMintSigner(
        bytes32 r,
        uint8 v,
        bytes32 s,
        string memory uri
    ) external {
        require(signerAllowance, 'ERC721Mintable: Signer is not allowed');
        require(check(r, v, s, uri), 'ERC721Mintable: Wrong signature');
        require(!ownerHaveURI[msg.sender][uri], 'ERC721Mintable: Already have');
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        tokenURIs[tokenId] = uri;
        ownerHaveURI[msg.sender][uri] = true;
        emit SafeMintSigner(msg.sender, tokenId);
    }

    function tokenURI(uint256 tokenId) public view override returns(string memory) {
        return tokenURIs[tokenId];
    }

    function check(
        bytes32 r,
        uint8 v,
        bytes32 s,
        string memory uri
    ) private view returns (bool) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                uri,
                msg.sender,
                address(this)
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
