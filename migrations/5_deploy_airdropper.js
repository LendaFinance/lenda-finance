var AirDropper = artifacts.require("AirDropper");

module.exports = async function(deployer, network, accounts) {
    // AirDropper deployment
    await deployer.deploy(AirDropper);
    const airdropper = await AirDropper.deployed();
};
