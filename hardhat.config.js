require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
      mumbai: {
        url: 'https://rpc-mumbai.maticvigil.com',
        accounts: [process.env.PRIVATE_KEY]
      }
  },
  etherscan: {
    apiKey: {
        mumbai: process.env.POLYGON_SCAN
    }
  }
};
