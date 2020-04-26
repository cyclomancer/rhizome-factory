const ethers = require('ethers');
web3.setProvider("http://localhost:9545")
const CcDAO = artifacts.require("CcDAO");
const mnemonic = "strong bright manual polar gorilla security kiss smart detect essence drastic table"
const provider = new ethers.providers.Web3Provider(web3.currentProvider);
const bareWallet = new ethers.Wallet.fromMnemonic(mnemonic)
const wallet = bareWallet.connect(provider)

contract("CcDAO", async accounts => {
  it("should deploy", async () => {
    const dao = await CcDAO.deployed()
    // console.log('current provider', web3.currentProvider)
    console.log('dao',dao.address)
    assert.equal(0, 0)
    return dao
  })
})


