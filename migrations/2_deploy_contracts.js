const NftRegistry = artifacts.require("NftRegistry");

module.exports = function (deployer) {
  deployer.deploy(NftRegistry);
};
