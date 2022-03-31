const APAEMECoin = artifacts.require('APAEMECoin');

module.exports = function (deployer) {
    deployer.deploy(APAEMECoin);
}