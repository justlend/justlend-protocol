const {ethers} = require("ethers");

const getMultiplierPerYear = (multiplierPerBlock, blocksPerYear, kink) => {
    const multiplier = ethers.BigNumber.from(multiplierPerBlock);
    const block = ethers.BigNumber.from(blocksPerYear);
    if(!kink.eq("0")) {
        const k = ethers.BigNumber.from(kink);
        return multiplier.mul(block.mul(k)).div("1000000000000000000");
    }else {
        return multiplier.mul(block);
    }
}

const getJumpMultiplierPerYear = (jumpMultiplierPerBlock, blocksPerYear) => {
    const multiplier = ethers.BigNumber.from(jumpMultiplierPerBlock);
    const block = ethers.BigNumber.from(blocksPerYear);

    const result = multiplier.mul(block);
    return result;
}

const getBaseRatePerYear = (baseRatePerBlock, blocksPerYear) => {
    const base  = ethers.BigNumber.from(baseRatePerBlock);
    const block = ethers.BigNumber.from(blocksPerYear);
    const result = base.mul(block);
    return result;
}

module.exports = {getMultiplierPerYear, getJumpMultiplierPerYear, getBaseRatePerYear};