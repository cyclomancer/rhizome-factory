var CcDAO = artifacts.require("CcDAO");
const ethers = require('ethers');

const mnemonic = "strong bright manual polar gorilla security kiss smart detect essence drastic table"
let provider = new ethers.providers.Web3Provider(web3.currentProvider);
let bareWallet = new ethers.Wallet.fromMnemonic(mnemonic)
let wallet = bareWallet.connect(provider)
module.exports = function(deployer) {
  // deployment steps
  wallet.getAddress().then(address => deployer.deploy(PGToken, "Rhizome", address))
}
