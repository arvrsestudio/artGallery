const NftRegistry = artifacts.require("NftRegistry");

module.exports = async function (deployer) {
  const accounts = await web3.eth.getAccounts()
  const feeAccount = accounts [0]

  await deployer.deploy(NftRegistry,feeAccount);
};
