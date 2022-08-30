var JumpRateModelV2 = artifacts.require("./JumpRateModelV2.sol");
var WhitePaperInterestRateModel = artifacts.require("./WhitePaperInterestRateModel.sol");
require('dotenv').config();

module.exports = async function(deployer) {
  //  ref: 0x0C3F8Df27e1A00b47653fDE878D68D35F00714C0
  // const cEtherInterestRate = {
  //   baseRate: "20000000000000000", // scaled by 1e18, equals to 0.02, 2%
  //   multiplier: "100000000000000000",  //scaled by 1e18, equals to 0.1, 10%
  // }

  // await deployer.deploy(
  //   WhitePaperInterestRateModel,
  //   cEtherInterestRate.baseRate,
  //   cEtherInterestRate.multiplier
  // );


  // ref: 0xFB564da37B41b2F6B6EDcc3e56FbF523bD9F2012
  const cDaiInterestRate = {
    baseRatePerYear: "0",
    multiplierPerYear: "40000000000000000",  // 4e+16, 0.04, 4%
    jumpMultiplierPerYear: "1090000000000000000", // 518455098934 * 2102400 (blockPerYear)
    kink: "800000000000000000",
  };

  await deployer.deploy(
    JumpRateModelV2,
    cDaiInterestRate.baseRatePerYear,
    cDaiInterestRate.multiplierPerYear,
    cDaiInterestRate.jumpMultiplierPerYear,
    cDaiInterestRate.kink,
    process.env.ADMIN
  );
};