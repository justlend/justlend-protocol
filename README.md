JustLend Protocol
=================

JustLend Protocol is an TRON smart contract protocol for supplying or borrowing assets. Through the jToken contracts, accounts on the TRON blockchain <b>supply</b> capital (TRX or TRC20 tokens) to receive jTokens or <b>borrow</b> assets from the protocol (holding other assets as collateral). The JustLend jToken contracts track these balances and algorithmically set interest rates for borrowers.

Before getting started with this repo, please read:

* The [Justlend Whitepaper](https://www.justlend.link/docs/justlend_whitepaper_en.pdf)
* The [Justlend Terms Of Use](https://www.justlend.link/docs/JustLend_Terms_of_Use_en.pdf)

For questions about interacting with JustLend, please visit [our Telegram Group](https://t.me/officialjustlend).


Contracts
=========

We detail a few of the core contracts in the Justlend protocol.

<dl>
  <dt>CToken, CErc20 and CEther</dt>
  <dd>The Justlend jTokens which are self-contained borrowing and lending contracts, are deployed from the code of CToken and CEther contracts. CToken contains the core logic and CErc20 and CEther add public interfaces for TRC20 tokens and TRX, respectively. Each jToken is assigned an interest rate and risk model (see InterestRateModel and Comptroller parts), and allows accounts to <b>mint</b> (supply capital), <b>redeem</b> (withdraw capital), <b>borrow</b> and <b>repay a borrow</b>. Each jToken is an TRC20 compliant token where balances represent ownership of the market.</dd>
</dl>

<dl>
  <dt>Comptroller</dt>
  <dd>The risk model contract, which validates permissible user actions and disallows actions if they do not fit certain risk parameters. For instance, the Comptroller enforces that each borrowing user must maintain a sufficient collateral balance across all cTokens.</dd>
</dl>

<dl>
  <dt>GovernorAlpha</dt>
  <dd>The administrator of the Justlend timelock contract. Holders of JST token may create and vote on proposals which will be queued into the Justlend timelock and then have effects on Justlend jToken and Comptroller contracts. This contract may be replaced in the future with a beta version.</dd>
</dl>

<dl>
  <dt>InterestRateModel</dt>
  <dd>Contracts which define interest rate models. These models algorithmically determine interest rates based on the current utilization of a given market (that is, how much of the supplied assets are liquid versus borrowed).</dd>
</dl>

<dl>
  <dt>ErrorReporter</dt>
  <dd>Library for tracking error codes and failure conditions.</dd>
</dl>

<dl>
  <dt>Exponential</dt>
  <dd>Library for handling fixed-point decimal numbers.</dd>
</dl>


<dl>
  <dt>WhitePaperInterestRateModel</dt>
  <dd>Initial interest rate model, as defined in the Whitepaper. This contract accepts a base rate and slope parameter in its constructor.</dd>
</dl>


<dl>
  <dt>Careful Math</dt>
  <dd>Library for safe math operations.</dd>
</dl>

<dl>
  <dt>SafeToken</dt>
  <dd>Library for safely handling Trc20 interaction.</dd>
</dl>

Deployment
----------
TronBox is being used in this project. Before getting started with the deployment script, please read:

* [Tronbox Tutorial](https://developers.tron.network/v3.7/docs/tron-box-user-guide)


## Compile and Deployment

To get started, first create and initialize a [NodeJS 8.0+ environment](https://github.com/nodejs/node). Next, clone the repo and install the developer dependencies:

### Setup
```
npm i
```

### OS requirement
 * Linux
 * Mac OS X

### Compile The Contract

Run this by using tronbox embedded solc:
 ```shell
 tronbox compile
```

Or you may want to use external compilers. You can get the compiler from [here](https://github.com/tronprotocol/solidity/releases/tag/tv_0.5.12)

And rename the compiler executable file to `solc512`, then compile the contracts with these commands.

```shell
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/contracts/Unitroller.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/contracts/Comptroller.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/contracts/Governance/WJST.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/contracts/Governance/GovernorAlpha.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/contracts/Timelock.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/contracts/JumpRateModelV2.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/contracts/WhitePaperInterestRateModel.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/contracts/CEther.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/contracts/CErc20Delegate.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/contracts/CErc20Delegator.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/contracts/PriceOracle/PriceOracle.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/contracts/PriceOracleProxy.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/contracts/PriceOracle/PriceOracle.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/contracts/PriceOracleProxy.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/contracts/Lens/CompoundLens.sol
```

### Deploy on Nile TestNet
Before use, `sample-env` should be renamed to `.env` with the added network config:
```
PRIVATE_KEY_NILE=YOUR_PRIVATE_KEY
RESERVER_ADMIN=YOUR_RESERVE_ADMIN_ADMIN_ADDRESS
ADMIN=YOUR_ADMIN_ADDRESS
```

Assuming all contracts haven't been deployed, the user must deploy the script one by one individually by replacing `xx` with the correct number of the file and then record the contract addresses and data to `../data/test-xxx.json`. Please feel free to modify the `migrations` and contract data.

```
tronbox migrate --network nile -f xx --to xx
```

For example, if you want to run `3_deploy_comptroller.js`, the command will be `tronbox migrate --network nile -f 3 --to 3`. 

Due to the limitation of Tronbox, `Governor.setTimelock()` is unable to be invoked among the migration script. Therefore, the related script is inside `script/2_setTimelock.js`. Please run it for setting up the timelock address from Governor.

## Contract Callers

The sample of contract invokers is inside the `script` folder.

Discussion
----------

For any concerns with the protocol, open an issue or visit us on [Telegram](https://t.me/officialjustlend) to discuss.

For security concerns, please email [support@justlend.org](mailto:support@justlend.org).

_© Copyright 2022 JustLend DAO
