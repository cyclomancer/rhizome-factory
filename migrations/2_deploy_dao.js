const CcDAO = artifacts.require("CcDAO");
const BondingCurve = artifacts.require("BondingCurve");
const ethers = require('ethers');

const mnemonic = "strong bright manual polar gorilla security kiss smart detect essence drastic table"
const provider = new ethers.providers.Web3Provider(web3.currentProvider);
const bareWallet = new ethers.Wallet.fromMnemonic(mnemonic)
const wallet = bareWallet.connect(provider)
module.exports = function(deployer) {
  console.log('deploy')
  // deployment steps
  return wallet.getAddress().then(address => deployer.deploy(CcDAO, "Rhizome", address).then(contract => {
    deployer.deploy(BondingCurve, contract.address)
  }))
}