// const { ethers } = require('ethers');
const { nile } = require('./utils/tronWeb');

const {CEther: cEtherData} = require('../../data/test-tokens.json');

const getCEtherContract = async () => {
    return await nile.contract().at(cEtherData.address);
}

const getParams = async () => {
    const cEther = await getCEtherContract();
    const name = await cEther.name().call();
    const interestRateModelAddress = await cEther.interestRateModel().call();
    const decimals = await cEther.decimals().call();
    const reserveFactor = await cEther.reserveFactorMantissa().call();
    const exchangeRate = await cEther.exchangeRateStored().call();
    const result = {
        name,
        decimals,
        interestRateModelAddress,
        reserveFactor: reserveFactor.toString(),
        exchangeRate: exchangeRate.toString(),
    };
    console.log(`cEther Params: ${JSON.stringify(result)}`);
    return result;
}

// const main = async () => {
//     await getParams();
// }

// main();

module.exports = {
    getCEtherContract,
    getParams,
};
