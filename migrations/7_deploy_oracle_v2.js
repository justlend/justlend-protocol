const {tokens, CErc20Delegator: CErc20DelegatorAddress, CEther} = require('../data/test-tokens.json');
const {oracleV1: oracleV1Address} = require('../data/test-oracle.json');
const PriceOracleProxy = artifacts.require("./PriceOracleProxy.sol");

module.exports = async function(deployer) {
    await deployer.deploy(
        PriceOracleProxy,
        process.env.ADMIN,
        oracleV1Address,
        CEther.address,
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
    );
    await PriceOracleProxy.deployed();
}
