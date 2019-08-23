var NAiToken = artifacts.require("./contract.sol");

module.exports = function(deployer) {
    return deployer.deploy(MedicalPass);
};
