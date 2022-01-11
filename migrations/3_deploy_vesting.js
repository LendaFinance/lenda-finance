const cfg = require('./lib/constants');
var Lenda = artifacts.require("Lenda");
var TeamVesting = artifacts.require("TeamVesting");

module.exports = async function(deployer, network, accounts) {

    const token = await Lenda.deployed();

    // TeamVesting deployment
    await deployer.deploy(TeamVesting,
                          token.address,
                          cfg.vestingStart.unix(),
                          cfg.cliffDuration,
                          cfg.vestingDuration,
                         );
    const vestingFactory = await TeamVesting.deployed();

    for(let addr of cfg.teamAddresses) {
        await vestingFactory.addTeamMember(addr);
    }
    await token.transfer(vestingFactory.address, cfg.teamTokens.toString());
    await vestingFactory.vest();
};
