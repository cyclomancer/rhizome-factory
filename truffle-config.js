const HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  networks: {
    development: {
     host: "127.0.0.1",
     port: 8545,
     network_id: "*",
    },
    rinkeby: {
      provider: function() {
        return new HDWalletProvider("charge together economy invite valley indicate close chuckle loud subject pact sponsor", 
        "https://rinkeby.infura.io/v3/9bd3b3cb534f47c8adc1173c27896118");
      },
      network_id: 4
    },
  },
  compilers: {
    solc: {
      version: "0.6.4",
    }
  }
}