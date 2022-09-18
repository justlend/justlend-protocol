const {ethers} = require("ethers");

const { nile } = require('../utils/tronWeb');
const calculator = require('../utils/calculator');

const {cEther: cEtherInterestRateAddress, cDai: cDaiInterestRateAddress} = require('../../../data/test-interest-rate.json');

const getInterestRateContract = async () => {
    return {
        cEtherInterestRateModel: await nile.contract().at(cEtherInterestRateAddress),
        cDaiInterestRateModel: await nile.contract().at(cDaiInterestRateAddress)
    };
}

const getParams = async () => {
    const {cEtherInterestRateModel, cDaiInterestRateModel} = await getInterestRateContract();
    let baseRate = await cEtherInterestRateModel.baseRatePerBlock().call();
    let blocksPerYear = await cEtherInterestRateModel.blocksPerYear().call();
    let multiplierPerBlock = await cEtherInterestRateModel.multiplierPerBlock().call();

    const cEtherData = {
        baseRatePerYear: calculator.getBaseRatePerYear(baseRate, blocksPerYear).toString(),
        blocksPerYear: blocksPerYear.toString(),
        multiplierPerYear: calculator.getMultiplierPerYear(multiplierPerBlock, blocksPerYear, ethers.BigNumber.from("0")).toString(),
    }
    
    baseRate = await cDaiInterestRateModel.baseRatePerBlock().call();
    blocksPerYear = await cDaiInterestRateModel.blocksPerYear().call();
    multiplierPerBlock = await cDaiInterestRateModel.multiplierPerBlock().call();
    jumpMultiplierPerBlock = await cDaiInterestRateModel.jumpMultiplierPerBlock().call();
    kink = await  cDaiInterestRateModel.kink().call();


    const cDaiData = {
        baseRatePerYear: calculator.getBaseRatePerYear(baseRate, blocksPerYear).toString(),
        blocksPerYear: blocksPerYear.toString(),
        multiplierPerYear: calculator.getMultiplierPerYear(multiplierPerBlock, blocksPerYear, kink).toString(),
        jumpMultiplierPerYear: calculator.getJumpMultiplierPerYear(jumpMultiplierPerBlock, blocksPerYear).toString(),
        kink: kink.toString(),
    }

    const result = {
        cEtherInterestRate: cEtherData,
        cDaiInterestRate: cDaiData,
    };
    console.log(`InterestRateModel Params: ${JSON.stringify(result)}`);
    return result;
}

// const main = async () => {
//     await getParams();
// }

// main();

module.exports = {
    getInterestRateContract,
    getParams,
}