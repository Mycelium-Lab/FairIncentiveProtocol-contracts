const { expect } = require("chai");
const assert = require("assert");
const { ethers } = require("hardhat")

describe('ERC20Universal Blacklist', () => {

    describe('Blacklist', async () => {

        let owner, signer, user;
        let token;
        let fpmanager;

        before(async () => {
            [owner, user, signer] = await ethers.getSigners()
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
                true,                              //_isBlacklist
                false,                              //_isRecoverable
                fpmanager.address                   //_fairProtocolManager
            )
            await token.deployed()
            await token.transfer(user.address, ethers.utils.parseEther('10'))
        })

        it('Should be deployed', async () => {
            const symbol = await token.symbol()
            assert(symbol == 'TT', 'Symbol is ok')
        })

        it('Should set user to blacklist', async () => {
            //can use
            await token.connect(user).transfer(signer.address, ethers.utils.parseEther('1'))
            await token.setBlacklistUsers([user.address])
            //can't use
            await expect(
                token.connect(user).transfer(signer.address, ethers.utils.parseEther('1'))
            ).to.be.revertedWith('ERC20: User in blacklist')
            //even to this user
            await expect(
                token.transfer(user.address, ethers.utils.parseEther('1'))
            ).to.be.revertedWith('ERC20: User in blacklist')
        })

        it('Should get blacklist time', async () => {
            const lastBlacklistID = await token.blacklistLastID()
            for (let i = 0; i <= parseInt(lastBlacklistID); i++) {
                const user = await token.blacklistUsers(i)
                const blockTime = await token.blacklistTime(user)
                console.log(user, blockTime.toString())
            }
        })

        it('Should delete user from blacklist', async () => {
            await token.deleteBlacklistUsers([user.address])
            //can use
            await token.connect(user).transfer(signer.address, ethers.utils.parseEther('1'))
        })

    })

})