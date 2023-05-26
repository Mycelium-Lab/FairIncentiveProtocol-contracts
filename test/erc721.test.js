// const { expect } = require("chai");
// const assert = require("assert");
// const { ethers } = require("hardhat")

// let signer, acc2;
// let nft;

// describe('ERC721Mintable', () => {

//     before(async () => {
//         [signer, acc2] = await ethers.getSigners()
//         const ERC721Mintable = await ethers.getContractFactory('ERC721Mintable')
//         nft = await ERC721Mintable.deploy('NFT', 'NFT', signer.address)
//         await nft.deployed()
//     })

//     it('Checks deployed contract', async () => {
//         const name = await nft.name()
//         assert(name, 'NFT')
//     })

//     it('Should mint nft with signer', async () => {
//         const uri = 'https://ipfs.io/ashdkahsdkhaskjhdkjash/1.json'
//         const _sign = await sign(uri, acc2.address, signer, nft.address)
//         const tx = await nft.connect(acc2).safeMintSigner(_sign.r, _sign.v, _sign.s, uri)
//         const res = await tx.wait()
//         console.log(res.events.find(v => v.event === 'SafeMintSigner').args.ID)
//         const createdUri = await nft.tokenURI(0)
//         assert(createdUri, uri)
//     })

// })

// async function sign(
//     uri, sender, signer, contractAddress
// ) {
//     const message = [uri, sender, contractAddress]
//     const hashMessage = ethers.utils.solidityKeccak256([
//         "string","uint160","uint160"
//     ], message)
//     const sign = await signer.signMessage(ethers.utils.arrayify(hashMessage));
//     const r = sign.substr(0, 66)
//     const s = `0x${sign.substr(66, 64)}`;
//     const v = parseInt(`0x${sign.substr(130,2)}`);
//     return {r,s,v}
// }