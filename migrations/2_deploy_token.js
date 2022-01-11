const cfg = require('./lib/constants');
var Lenda = artifacts.require("Lenda");

module.exports = async function(deployer, network, accounts) {
    // Token deployment
    await deployer.deploy(Lenda, cfg.preMinted.toString(), cfg.maxMinted.toString(), '18');
    const token = await Lenda.deployed();
};
