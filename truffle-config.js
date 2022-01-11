const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const secretTest = fs.readFileSync(".secret-test").toString().trim();
const secretDeployer = fs.readFileSync(".secret-deployer").toString().trim();

module.exports = {
  networks: {
    development: {
        host: "127.0.0.1",
        port: 7545,
        network_id: "*", // Match any network id
    },
    develop: {
        port: 8545
    },
    bscTestnet: {
        provider: () => new HDWalletProvider(secretTest, `https://data-seed-prebsc-1-s1.binance.org:8545`),
        network_id: 97,
        confirmations: 10,
        timeoutBlocks: 200,
        skipDryRun: true
    },
    bsc: {
        provider: () => new HDWalletProvider(secretDeployer, `https://bsc-dataseed1.binance.org`),
        network_id: 56,
        confirmations: 10,
        timeoutBlocks: 200,
        skipDryRun: true
    },
  },
  compilers: {
      solc: {
          version: "^0.5.0"
      }
  }
};
