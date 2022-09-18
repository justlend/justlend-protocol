const { nile } = require('../utils/tronWeb');
const trxOption = require('../utils/trx');

const {getCErc20DelegatorContract, getSingleParams} = require('../helper/cErc20');
const {getComptrollerContract} = require('../helper/Comptroller');

const {unitroller: comptrollerAddress} = require('../../data/test-comptroller.json');
const {CErc20Delegator} = require('../../data/test-tokens.json');
const {abi: comptrollerAbi} = require('../../build/contracts/Comptroller.json');

const getErc20Contract = async (erc20Address) => {
    return await nile.contract().at(erc20Address);
}

const enterMarkets = async (comptroller, cTokenAddresses) => {
    await comptroller.enterMarkets(cTokenAddresses).send(trxOption);
}

const mintToken = async (comptroller, cToken, amount) => {
    await enterMarkets(comptroller, [cToken.address], amount);
    
    const cTokenParam = await getSingleParams(cToken);
    console.log(JSON.stringify(cTokenParam));
    const underlyingAddress = cTokenParam.underlying; 

    const underlying = await getErc20Contract(underlyingAddress);
    await underlying.approve(cToken.address, '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff').send(trxOption);

    await cToken.mint(amount).send(trxOption);
    return await comptroller.getAccountLiquidity( process.env.ADMIN).call();
}

const main = async () => {
    const comptroller = await getComptrollerContract(comptrollerAbi, comptrollerAddress);
    const addr = CErc20Delegator[0];
    const cErc20 = await getCErc20DelegatorContract(addr);
    const result = await mintToken(comptroller, cErc20, '100000000');
    console.log(result[1].toString());
}

main();