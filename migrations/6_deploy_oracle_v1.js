const { tokens } = require('../data/test-tokens.json');
const PriceOracleV1Art = artifacts.require("./PriceOracleV1.sol");

module.exports = async function (deployer) {
  await deployer.deploy(PriceOracleV1Art, process.env.ADMIN, "0x0000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000");
  
  const priceOracleV1Instance = await PriceOracleV1Art.deployed();
  const setPrice = tokens.map(async (v) => {
    await priceOracleV1Instance.setPrice(v, "1000000000000000000");
  });
  await Promise.all(setPrice);
};
