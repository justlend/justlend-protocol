const { ethers } = require('ethers');
const tokenData = require('../data/test-tokens.json');
const { unitroller } = require('../data/test-comptroller.json');
require('dotenv').config();

const cEther = artifacts.require("./CEther.sol");
const cErc20Delegator = artifacts.require('./CErc20Delegator.sol');
const cErc20Delegate = tokenData.cErc20Delegate;
const tokens = tokenData.tokens;
const tokenConfig = tokenData.tokenConfig;

module.exports = async(deployer) => {
    await deployer.deploy(
        cEther,
        unitroller,
        tokenData.CEther.interestRateModel,
        tokenData.CEther.exchangeRate, 
        tokenData.CEther.name,
        tokenData.CEther.symbol,
        tokenData.CEther.decimals,
        process.env.ADMIN,
        process.env.RESERVER_ADMIN,
        tokenData.CEther.reserveFactor, // scaled by 1e18, equals to 0.2, 20%
    );


    const cErc20DelegateDeployer = cErc20Delegate.map(async (v,i) => {
        console.log(`Deploying ${i} of cErc20Delegate...`);
        console.log(`Underlying Address: ${tokens[i]}`);
        console.log(`TokenConfig: ${JSON.stringify(tokenConfig[i])}`);

        await deployer.deploy(
            cErc20Delegator,
            tokens[i],
            unitroller,
            tokenConfig[i].interestRateModel,
            tokenConfig[i].exchangeRate,
            tokenConfig[i].name,
            tokenConfig[i].symbol,
            tokenConfig[i].decimals,
            process.env.ADMIN,
            process.env.RESERVER_ADMIN,
            v,
            "0x",  //Currently Unused
            tokenConfig[i].reserveFactor,
        );
    })

    await Promise.all(cErc20DelegateDeployer);
}
