require("@nomicfoundation/hardhat-toolbox");
require ('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
const {PrivateKey, mainnetUrl, RinkebyURL,RopstenUrl, KovanURL, MumbaiURL, EtherscanApiKey} = process.env;


module.exports = {
  solidity: "0.8.7",
  defaultNetwork: "hardhat",
  networks: {
    rinkeby: {
      url: RinkebyURL,
      accounts: [PrivateKey]
    },
    mumbai: {
      url: MumbaiURL,
      accounts: [PrivateKey]
    },
    kovan: {
      url: KovanURL,
      accounts: [PrivateKey]
    },
    ropsten: {
      url: RopstenUrl,
      accounts: [PrivateKey]
    },
    mainnet: {
      url: mainnetUrl,
      accounts: [PrivateKey]
    }
  },
    etherscan: {
      apiKey: EtherscanApiKey
    },

};