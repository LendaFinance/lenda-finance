const cfg = require('./lib/constants');
var Lenda = artifacts.require("Lenda");
var LendaSale = artifacts.require("LendaSale");

module.exports = async function(deployer, network, accounts) {
    const token = await Lenda.deployed();

    // Crowdsale deployment
    await deployer.deploy(LendaSale,
                          token.address,
                          accounts[0],
                          cfg.rate,
                          cfg.minFunding,
                          cfg.fundingGoal,
                          cfg.openingTime.unix(),
                          cfg.closingTime.unix(),
                         );
    const crowdsale = await LendaSale.deployed();
    await token.transfer(crowdsale.address, cfg.icoTokens.toString());
};
