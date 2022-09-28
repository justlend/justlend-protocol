const GovernorBravoDelegate = artifacts.require("./GovernorBravoDelegate.sol");
const GovernorBravoDelegator = artifacts.require("./GovernorBravoDelegator.sol");

const TIMELOCK_ADDRESS = process.env.TIMELOCK_ADDRESS;
const WJST_ADDRESS = process.env.WJST_ADDRESS;
const VOTING_PERIOD = process.env.VOTING_PERIOD;
const VOTING_DELAY = process.env.VOTING_DELAY;
const PROPOSAL_THRESHOLD = process.env.PROPOSAL_THRESHOLD;
const ADMIN_ADDRESS = process.env.ADMIN_ADDRESS;

module.exports = async function(deployer) {
    await deployer.deploy(GovernorBravoDelegate);
    await GovernorBravoDelegate.deployed();
    await deployer.deploy(
        GovernorBravoDelegator,
        TIMELOCK_ADDRESS,
        WJST_ADDRESS,
        ADMIN_ADDRESS,
        GovernorBravoDelegate.address,
        VOTING_PERIOD,
        VOTING_DELAY,
        PROPOSAL_THRESHOLD
    );
}