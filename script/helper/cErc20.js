const { nile } = require('../utils/tronWeb');
const tokenData = require('../../data/test-tokens.json');

const getCErc20DelegatorContracts = async () => {
    const result = tokenData.CErc20Delegator.map(async (address)=>{
        return await getCErc20DelegatorContract(address);
    });
    return await Promise.all(result);
}

const getCErc20DelegatorContract = async (address) => {
    return await nile.contract().at(address);
}

const getSingleParams = async (contract) => {
    const underlying = await contract.underlying().call();
    const underlyingName = await contract.name().call();
    const isCToken = await contract.isCToken().call();
    const exchangeRate = await contract.exchangeRateStored().call();
    const reserveFactor = await contract.reserveFactorMantissa().call();
    const implementation = await contract.implementation().call();
    const decimals = await contract.decimals().call();

    const result = {
        underlying: nile.address.fromHex(underlying),
        underlyingName,
        isCToken,
        implementation: nile.address.fromHex(implementation),
        decimals: decimals.toString(),
        exchangeRate: exchangeRate.toString(),
        reserveFactor: reserveFactor.toString(),
    };
    return result;
}

const getMultiplieParams = async (contracts) => {
    const result = contracts.map(async (contract)=> {
        return getSingleParams(contract);
    });
    return await Promise.all(result);
}

// const main = async () => {
//     const contracts = await getCErc20DelegatorContracts();
//     const params = await getMultiplieParams(contracts);
//     params.map(p=>console.log(JSON.stringify(p)));
// }

// main();

module.exports = {
    getCErc20DelegatorContract, getSingleParams, getMultiplieParams
};

