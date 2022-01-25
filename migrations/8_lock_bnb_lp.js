const cfg = require('./lib/constants');
var TokenTimelock = artifacts.require("TokenTimelock");

module.exports = async function(deployer, network, accounts) {
    // TokenTimelock deployment
    await deployer.deploy(TokenTimelock,
                          cfg.bnbLpToken,
                          cfg.lockerAddress,
                          cfg.lpUnlockTime.unix(),
                         );
    const lock = await TokenTimelock.deployed();
};
