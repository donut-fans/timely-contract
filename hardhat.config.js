require("@nomicfoundation/hardhat-toolbox");

let dotenv = require('dotenv')
dotenv.config({path:"./.env"})

const privateKey1 = process.env.PRIVATE_KEY_1
const mnemonic1 = process.env.MNEMONIC_1

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",

  networks:{
    sepolia:{
      url: "https://ethereum-sepolia.blockpi.network/v1/rpc/public",
      accounts: [privateKey1],
      chainId: 11155111,
    },
    goerli: {
      url: "https://eth-goerli.api.onfinality.io/public",
      accounts: [privateKey1],
      chainId: 5,
    },
    mumbai: {
      url: "https://endpoints.omniatech.io/v1/matic/mumbai/public",
      accounts: {
        mnemonic: mnemonic1,
      },
      chainId: 80001,
    },
  },

  etherscan:{
    apiKey:process.env.ETHERSCAN_API_KEY
  }
};
