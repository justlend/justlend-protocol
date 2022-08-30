const { nile } = require('./utils/tronWeb');
const {tokens} = require('../../data/test-tokens.json');
const {oracleV1 : oracleV1Address} = require('../../data/test-oracle.json');

const getPriceOracleV1Contract = async() => {
    return await nile.contract().at(oracleV1Address);
}

const getPrice = async(underlying) => {
    const contract = await getPriceOracleV1Contract();
    const result = await contract.assetPrices(underlying).call();
    return result.toString();
}

const getPrices = async() => {
    let assets = [
        {
            address: "T9yD14Nj9j7xAB4dbGeiX9h8unkKLxmGkn",
            name: "usdc"
        },
        {
            address: "T9yD14Nj9j7xAB4dbGeiX9h8unkKT76qbH",
            name: "usdt"
        }        
    ]

    for(let i = 2; i<tokens.length;i++){
        assets.push({
            address: tokens[i],
            name: `T${i+1}`
        })
    }

    const result = assets.map(async (v) =>{ 
        return {address: v.address, name: v.name, price: await getPrice(v.address)}
    });
    const finalResult = await Promise.all(result);
    return finalResult;
}

// const main = async() =>{
//     const prices = await getPrices();
//     console.log(JSON.stringify(prices));
// }

// main();

module.exports = {
    getPriceOracleV1Contract,
    getPrice,
    getPrices
}