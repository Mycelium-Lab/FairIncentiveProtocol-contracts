const { expect } = require("chai");
const assert = require("assert");
const { ethers } = require("hardhat")

let usedSignature

describe('ERC20Universal', () => {

    describe('Capped Pausable Burnable', async () => {

        let signer, owner, user;
        let token;
        let fpmanager;

        before(async () => {
            [signer, owner, user] = await ethers.getSigners()
            const FairProtocolManager = await ethers.getContractFactory('FairProtocolERC20Manager')
            fpmanager = await FairProtocolManager.deploy(signer.address)
            await fpmanager.deployed()
            const ERC20Universal = await ethers.getContractFactory('ERC20Universal')
            token = await ERC20Universal.deploy(
                'TestToken',                        //_name
                'TT',                               //_symbol
                0,                                  //_contractType
                ethers.utils.parseEther('1000000'), //cap_
                ethers.utils.parseEther('1000'),    //_initialSupply
                true,                               //_isPausable
                true,                               //_isBurnable
                false,                              //_isBlacklist
                false,                              //_isRecoverable
                fpmanager.address                   //_fairProtocolManager
            )
            await token.deployed()
        })

        it('Should be deployed', async () => {
            const symbol = await token.symbol()
            assert(symbol == 'TT', 'Symbol is ok')
        })

        it('Should transfer tokens to user', async () => {
            const amount = ethers.utils.parseEther('1')
            const currentCount = await fpmanager.currentCount(user.address, token.address)
            const signature = await sign(
                amount,
                user.address,
                signer,
                fpmanager.address,
                token.address,
                currentCount
            )
            usedSignature = signature
            const balanceBefore = await token.balanceOf(user.address)
            await fpmanager.connect(user).mintSigner(
                signature.r,
                signature.v,
                signature.s,
                token.address,
                amount
            )
            const balanceAfter = await token.balanceOf(user.address)
            assert(balanceAfter > balanceBefore, 'Minter')
        })

        it('Should not allow to mint with the same sign', async () => {
            const amount = ethers.utils.parseEther('1')
            await expect(
                fpmanager.connect(user).mintSigner(
                    usedSignature.r,
                    usedSignature.v,
                    usedSignature.s,
                    token.address,
                    amount
                )
            ).to.be.rejectedWith('FairProtocolERC20Manager: Wrong signature')
        })

    })

    describe('Fixed Pausable Burnable', async () => {

        let signer, owner, user;
        let token;
        let fpmanager;

        before(async () => {
            [signer, owner, user] = await ethers.getSigners()
            const FairProtocolManager = await ethers.getContractFactory('FairProtocolERC20Manager')
            fpmanager = await FairProtocolManager.deploy(signer.address)
            await fpmanager.deployed()
            const ERC20Universal = await ethers.getContractFactory('ERC20Universal')
            token = await ERC20Universal.deploy(
                'TestToken',                        //_name
                'TT',                               //_symbol
                1,                                  //_contractType
                0,                                  //cap_
                ethers.utils.parseEther('1000'),    //_initialSupply
                true,                               //_isPausable
                true,                               //_isBurnable
                false,                              //_isBlacklist
                false,                              //_isRecoverable
                fpmanager.address                   //_fairProtocolManager
            )
            await token.deployed()
        })

        it('Should be deployed', async () => {
            const symbol = await token.symbol()
            assert(symbol == 'TT', 'Symbol is ok')
        })

        it('Should transfer tokens to user', async () => {
            const amount = ethers.utils.parseEther('1')
            const currentCount = await fpmanager.currentCount(user.address, token.address)
            const signature = await sign(
                amount,
                user.address,
                signer,
                fpmanager.address,
                token.address,
                currentCount
            )
            const balanceBefore = await token.balanceOf(user.address)
            await fpmanager.connect(user).mintSigner(
                signature.r,
                signature.v,
                signature.s,
                token.address,
                amount
            )
            const balanceAfter = await token.balanceOf(user.address)
            assert(balanceAfter > balanceBefore, 'Minter')
        })

    })

})

async function sign(
    amount, senderAddress, signer, managerAddress, tokenAddress, count
) {
    const message = [amount, senderAddress, tokenAddress, managerAddress, count]
    const hashMessage = ethers.utils.solidityKeccak256([
        "uint256","uint160","uint160","uint160", "uint256"
    ], message)
    const sign = await signer.signMessage(ethers.utils.arrayify(hashMessage));
    const r = sign.substr(0, 66)
    const s = `0x${sign.substr(66, 64)}`;
    const v = parseInt(`0x${sign.substr(130,2)}`);
    return {r,s,v}
}