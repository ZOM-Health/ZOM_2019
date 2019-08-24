var Staking = artifacts.require("./Staking.sol");

module.exports = function(deployer) {
    return deployer.deploy(Staking);
};
