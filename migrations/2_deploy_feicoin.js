const FEICoin = artifacts.require('FEICoin');

module.exports = function (deployer) {
    deployer.deploy(FEICoin);
}