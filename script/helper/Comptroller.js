const {unitroller: unitrollerAddress} = require('../../data/test-comptroller.json');
const {abi: comptrollerAbi} = require('../../build/contracts/Comptroller.json');
const {CErc20Delegator, CEther} = require('../../data/test-tokens.json');
const { nile } = require('../utils/tronWeb');

const getComptrollerContract = async (abi, unitroller) => {
    return await nile.contract(abi, unitroller);
}

const getAllMarkets = async (contract) => {
    return await contract.getAllMarkets().call();
}

const getMarketData = async (contract, cToken) => {
    return await contract.markets(cToken).call();
}

const getAllMarketData = async (contract, cTokens) => {
    return await Promise.all(cTokens.map(async (v)=>{
        const data = await getMarketData(contract, v);
        return {
            tokenAddress: v,
            isListed: data[0],
            collateralFactor: data[1].toString(),
        };
    }));
}

const getPriceOracle = async (contract) => {
    return await contract.oracle().call();
}

// const main = async () => {
//     const comptrollerContract = await getComptrollerContract(comptrollerAbi, unitrollerAddress);
//     console.log(`PriceOracle Address: ${nile.address.fromHex(await getPriceOracle(comptrollerContract))}`);
    
//     const markets = await getAllMarkets(comptrollerContract);
//     console.log(`Markets: ${JSON.stringify(markets.map(v=>nile.address.fromHex(v)))}`);

//     const tokens = [...CErc20Delegator, CEther.address];
//     const marketData = await getAllMarketData(comptrollerContract, tokens);
//     console.log(`Market Data: ${JSON.stringify(marketData)}`);
// }

// main();

module.exports = {
    getComptrollerContract,
    getAllMarkets,
    getMarketData,
    getAllMarketData,
    getPriceOracle
}