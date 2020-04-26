const ethers = require('ethers');
web3.setProvider("http://localhost:9545")
const CcDAO = artifacts.require("CcDAO");
const mnemonic = "strong bright manual polar gorilla security kiss smart detect essence drastic table"
const provider = new ethers.providers.Web3Provider(web3.currentProvider);
const bareWallet = new ethers.Wallet.fromMnemonic(mnemonic)
const wallet = bareWallet.connect(provider)

const bigValue = 1000000000
const smallValue = 100000000

contract("CcDAO", async accounts => {
  it("should deploy", async () => {
    const dao = await CcDAO.deployed()
    // console.log('current provider', web3.currentProvider)
    console.log('dao',dao.address)
    assert.equal(0, 0)
    return dao
  })

  it("should register new projects and their funding targets", async () => {
    const dao = await CcDAO.deployed()
    const transaction = { address: dao.address, value: bigValue }
    const transfer = await wallet.sendTransaction(transaction)
    const contract = new ethers.Contract(dao.address, dao.abi, provider)
    let projectEvent = new Promise((resolve, reject) => {
      contract.on('Transfer', (_project, _amount, event) => {
          event.removeListener();

          resolve({
              project: _project,
              amount: _amount
          });
      });

      setTimeout(() => {
          reject(new Error('timeout'));
      }, 60000)
    });
    const tx = await contract.addProject(wallet.address, smallValue)
    await tx.wait()
    console.log('addProject response', tx.data)
    assert.equal(tx.data, true)
    const event = await projectEvent
    assert.equal(event.amount, smallValue)
    assert.equal(event.project, wallet.address)
    assert.equal(transfer.value, contract.balance)
    return dao
  })

  it("should release funds to a project", async () => {
    const dao = await CcDAO.deployed()
    const contract = new ethers.Contract(dao.address, dao.abi, provider)
    const prevBalance = wallet.balance
    let allocationEvent = new Promise((resolve, reject) => {
      contract.on('Allocation', (_project, _amount, event) => {
          event.removeListener();

          resolve({
              project: _project,
              amount: _amount
          });
      });

      setTimeout(() => {
          reject(new Error('timeout'));
      }, 60000)
    });
    const tx = await contract.allocate(wallet.address)
    await tx.wait()
    console.log('allocate response', tx.data)
    assert.equal(tx.data, true)
    const event = await allocationEvent
    assert(wallet.balance > event.amount - tx.gasPrice + prevBalance)

    return dao
  })
})


