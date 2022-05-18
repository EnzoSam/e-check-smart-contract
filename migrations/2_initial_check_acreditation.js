const CheckAccreditation = artifacts.require("CheckAccreditation");

module.exports = function (deployer) {
  deployer.deploy(CheckAccreditation);
};
