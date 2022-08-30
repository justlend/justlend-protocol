const { nile } = require('./utils/tronWeb');
const trxOption = require('./utils/trx');

const {unitroller: comptrollerAddress} = require('../data/test-comptroller.json');
const {oracle: oracleAddress} = require('../data/test-oracle.json');
const {CErc20Delegator, CEther, tokenConfig} = require('../data/test-tokens.json');
const {abi: comptrollerAbi} = require('../build/contracts/Comptroller.json');


const getComptrollerContract = async (unitroller, abi) => {
    return await nile.contract(abi, unitroller);
}

const setPriceOracle = async (contract, priceOracle) => {
    return await contract._setPriceOracle(priceOracle).send(trxOption);
}

const setMaxAssets = async (contract, numOfAssets) => {
    return await contract._setMaxAssets(numOfAssets).send(trxOption);
}

const setCloseFactor = async (contract, closeFactor) => {
    return await contract._setCloseFactor(closeFactor).send(trxOption);
}

const setCollateralFactor = async (contract, cToken, collateralFactor) => {
    return await contract._setCollateralFactor(cToken, collateralFactor).send({trxOption});
}

const setLiquidationIncentive = async (contract, liquidationIncentive) => {
    return await contract._setLiquidationIncentive(liquidationIncentive).send({trxOption});
}

const addMarket = async (contract, cToken) => {
    return await contract._supportMarket(cToken).send({trxOption});
}

const setPauseGuardian = async (contract, admin) => {
    return await contract._setPauseGuardian(admin).send({trxOption});
}

const setMintPaused = async (contract, cToken, state) => {
    return await contract._setMintPaused(cToken, state).send({trxOption});
}

const setBorrowPaused = async (contract, cToken, state) => {
    return await contract._setBorrowPaused(cToken, state).send({trxOption});
}

const setTransferPaused = async (contract, state) => {
    return await contract._setTransferPaused(state).send({trxOption})
}

const setSeizePaused = async (contract, state) =>{
    return await contract._setSeizePaused(state).send({trxOption});
}

const main = async () => {
    const comptrollerContract = await getComptrollerContract(comptrollerAddress, comptrollerAbi);

    // Set Comptroller Basic Setting
    // console.log(JSON.stringify(await setPriceOracle(comptrollerContract, oracleAddress)));
    // console.log(await setMaxAssets(comptrollerContract, 10));
    // console.log(await setLiquidationIncentive(comptrollerContract, "1080000000000000000"));
    // console.log(await setCloseFactor(comptrollerContract, "500000000000000000"));

    // // Add Tokens
    // const cTokens = [...CErc20Delegator, CEther.address];
    // const addMarketsPromise = cTokens.map(async (t) =>{return await addMarket(comptrollerContract, t)});
    // await Promise.all(addMarketsPromise);

    // // Set CollateralFactor Individually
    // console.log(await setCollateralFactor(comptrollerContract, CEther.address, CEther.collateralFactor)); 
    // for(let i=0; i<CErc20Delegator.length; i++) {
    //     console.log(await setCollateralFactor(comptrollerContract, CErc20Delegator[i], tokenConfig[i].collateralFactor));
    // }
}

main();
