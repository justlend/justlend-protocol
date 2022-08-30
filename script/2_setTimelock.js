const { nile } = require('./utils/tronWeb');
const trxOption = require('./utils/trx');

const governance = require('../data/test-governance.json');

const getGovernorAlphaContract = async () => {
    return await nile.contract().at(governance.governorAlpha);
}

const setTimelock = async (contract, timelock) => {
    return await contract.setTimeLock(timelock).send({trxOption});
}

const main = async () => {
    const governorContract = await getGovernorAlphaContract();
    console.log(await setTimelock(governorContract, governance.timelock));
}

main();
