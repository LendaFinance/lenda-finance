const cfg = require('./lib/constants');
const StakingLenda = artifacts.require("StakingLenda");

module.exports = async function(deployer, network, accounts) {
    // StakingLenda deployment
    await deployer.deploy(
        StakingLenda,
        cfg.preMinted.toString(),
        cfg.maxMinted.toString(),
        '18',
        cfg.annualMintTarget.toString(),
        cfg.cooldown
    );
    const token = await StakingLenda.deployed();

    if(network == 'development') {
        for(let acc of accounts) {
            if(acc == accounts[0]) continue;
            await token.transfer(acc, 10_000_000n * cfg.weiRate);
        }
    }
};
