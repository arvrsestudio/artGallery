const NftRegistry = artifacts.require("NftRegistry");

module.exports = async function (deployer) {
  const accounts = await web3.eth.getAccounts();
  const feeAccount = accounts[0];
  const feePercent = 10;
  deployer.deploy(NftRegistry, feeAccount, feePercent);
};
