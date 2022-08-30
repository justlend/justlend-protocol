const WJST = artifacts.require("./WJST.sol");
const GovernorAlpha = artifacts.require("./GovernorAlpha.sol");
const Timelock = artifacts.require("./Timelock.sol");

const {tokens} = require('../data/test-tokens.json');

module.exports = async function(deployer) {
    await deployer.deploy(WJST, "0x0000000000000000000000000000000000000000", tokens[tokens.length - 1]);
    const wjst = await WJST.deployed();

    await deployer.deploy(GovernorAlpha, WJST.address, process.env.ADMIN);
    const governorAlpha = await GovernorAlpha.deployed();

    await deployer.deploy(Timelock, GovernorAlpha.address, `${86400*4}`); //4 days
    const timelock = await Timelock.deployed();

    await wjst.setGovernorAlpha(GovernorAlpha.address);
    console.log(governorAlpha);
    // await governorAlpha.setTimelock(timelock.address); bug, cant execute this function, need to go to tronscan
}
