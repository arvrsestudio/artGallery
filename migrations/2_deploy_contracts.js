const CifiPowa = artifacts.require("CifiPowa");
const ArtGallery = artifacts.require("ArtGallery");
module.exports = async function (deployer) {
  const accounts = await web3.eth.getAccounts();
  const feeAccount = accounts[0];
  console.log(feeAccount);
  // await deployer.deploy(NftRegistry,feeAccount,{gas: 4612388});
  // await deployer.deploy(CifiPowa);
  await deployer.deploy(ArtGallery);
};
