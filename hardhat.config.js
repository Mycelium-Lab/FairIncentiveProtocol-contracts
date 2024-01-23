require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    polygonMumbai: {
      url: 'https://rpc-mumbai.maticvigil.com',
      accounts: [process.env.PRIVATE_KEY]
    },
    bnbTest: {
      url: 'https://bsc-testnet.publicnode.com',
      accounts: [process.env.PRIVATE_KEY]
    },
    sapphireTest: {
      url: 'https://testnet.sapphire.oasis.dev',
      accounts: [process.env.PRIVATE_KEY],
      chainId: 23295
    }
  },
  etherscan: {
    apiKey: {
      polygonMumbai: process.env.POLYGON_SCAN
    }
  }
};
