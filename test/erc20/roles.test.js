const { expect } = require("chai");
const assert = require("assert");
const { ethers } = require("hardhat")

describe('ERC20Universal Roles', () => {

    describe('Roles control', async () => {

        let owner, manager, signer;
        let token;
        let fpmanager;

        before(async () => {
            [owner, manager, signer] = await ethers.getSigners()
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
            await token.setAllowedUser(manager.address)
        })

        it('Should be deployed', async () => {
            const symbol = await token.symbol()
            assert(symbol == 'TT', 'Symbol is ok')
        })

        it('Manager should pause contract', async () => {
            const pausedBefore = await token.paused()
            assert(!pausedBefore, "Not paused")
            await token.connect(manager).pause()
            const pausedAfter = await token.paused()
            assert(pausedAfter, 'Paused')
        })

        it('Should take back allowance from manager', async () => {
            await token.deleteAllowedUser(manager.address)
            await expect(
                token.connect(manager).pause()
            ).to.be.revertedWith('ERC20: Not allowed wallet')
        })

        it('Should get allowed users', async () => {
            const lastAllowedUserID = parseInt(await token.lastAllowedUserID())
            for (let i = 0; i <= lastAllowedUserID; i++) {
                console.log(await token.allowedUsersList(i))
            }
        })

    })

})