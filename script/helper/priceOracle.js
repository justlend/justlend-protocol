const { nile } = require('./utils/tronWeb');
const { oracleV1: oracleV1Address, oracle: oracleAddress } = require('../../data/test-oracle.json');

const getPriceOracleContract = async () => {
    const v1 = await nile.contract().at(oracleV1Address);
    const proxy = await nile.contract().at(oracleAddress);
    return {
        v1, proxy
    }
}

const getPrice = async (proxy, cToken) => {
    const result = await proxy.getUnderlyingPrice(cToken).call();
    return result.toString();

}

const getPrices = async (proxy) => {
    let cAssets = [
        {
            address: "TRV3vxD4yUgqu1FMJ5KNxQzSwmThHP1npz",
            name: "usdc"
        },
        {
            address: "TPXQFKeLjcXczthgV3Kj1MXAy1kADVTCUW",
            name: "usdt"
        },
        {
            address: "TPPq48YYWCPwHt5Kt4fPrHnEfCJqtzEUUm",
            name: "dai"
        },
        {
            address: "TMJGEhLjCBCiHKG3vY9niri6yw841Sqbaa",
            name: "T4"
        },
        {
            address: "TKNwKkZSjTQcz5AgoMNqabnuryxNuZJY5c",
            name: "T5"

        }
    ];

    const result = cAssets.map(async (v) => {
        return { address: v.address, name: v.name, price: (await getPrice(proxy, v.address)).toString() }
    });
    const finalResult = await Promise.all(result);
    return finalResult;
}

const getSaiPrice = async (proxy) => {
    const result = await proxy.saiPrice().call();
    return result.toString();
}

// const main = async () => {
//     const { proxy } = await getPriceOracleContract();
//     const prices = await getPrices(proxy);
//     console.log(`Asset Prices: ${JSON.stringify(prices)}`);

//     const saiPrice = await getSaiPrice(proxy);
//     console.log(`Sai Price: ${saiPrice}`);
// }

// main();

module.exports = {
    getPriceOracleContract,
    getPrice,
    getPrices,
    getSaiPrice,
}