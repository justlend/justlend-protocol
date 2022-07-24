JustLend Protocol
=================

JustLend Protocol is an TRON smart contract protocol for supplying or borrowing assets. Through the jToken contracts, accounts on the TRON blockchain *supply* capital (TRX or TRC-20 tokens) to receive jTokens or *borrow* assets from the protocol (holding other assets as collateral). The JustLend jToken contracts track these balances and algorithmically set interest rates for borrowers.

Before getting started with this repo, please read:

* The [Justlend Whitepaper](https://www.justlend.link/docs/justlend_whitepaper_en.pdf)
* The [Justlend Terms Of Use](https://www.justlend.link/docs/JustLend_Terms_of_Use_en.pdf)

For questions about interacting with JustLend, please visit [our Telegram Group](https://t.me/officialjustlend).



Contracts
=========


We detail a few of the core contracts in the Justlend protocol.

<dl>
  <dt>CToken, CErc20 and CEther</dt>
  <dd>The Justlend jTokens, which are self-contained borrowing and lending contracts. CToken contains the core logic and CTrc20 and CEther add public interfaces for Trc20 tokens and TRX, respectively. Each jToken is assigned an interest rate and risk model (see InterestRateModel and Comptroller sections), and allows accounts to *mint* (supply capital), *redeem* (withdraw capital), *borrow* and *repay a borrow*. Each jToken is an TRC-20 compliant token where balances represent ownership of the market.</dd>
</dl>

<dl>
  <dt>Comptroller</dt>
  <dd>The risk model contract, which validates permissible user actions and disallows actions if they do not fit certain risk parameters. For instance, the Comptroller enforces that each borrowing user must maintain a sufficient collateral balance across all cTokens.</dd>
</dl>


<dl>
  <dt>GovernorAlpha</dt>
  <dd>The administrator of the Justlend timelock contract. Holders of Comp token may create and vote on proposals which will be queued into the Justlend timelock and then have effects on Justlend jToken and Comptroller contracts. This contract may be replaced in the future with a beta version.</dd>
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


Compile The Contract
=========

You can get the compiler from [here](https://github.com/tronprotocol/solidity/releases/tag/tv_0.5.12)

And rename the compiler executable file to `solc512`

```shell
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/Unitroller.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/Comptroller.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/Governance/WJST.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/Governance/GovernorAlpha.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/Timelock.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/JumpRateModelV2.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/WhitePaperInterestRateModel.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/CEther.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/CErc20Delegate.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/CErc20Delegator.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/PriceOracle/PriceOracle.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/PriceOracleProxy.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/PriceOracle/PriceOracle.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/PriceOracleProxy.sol
./solc512   --allow-paths $YOUR_PATH/justlend-protocol/, --bin --abi --optimize $YOUR_PATH/justlend-protocol/Lens/CompoundLens.sol
```


Deployed Contract Address
=========

```

Unitroller TGjYzgCyPobsNS9n6WcbdLVR9dH7mWqFx7
Comptroller TB23wYojvAsSx6gR8ebHiBqwSeABiBMPAr
WJST TCczUFrX1u4v1mzjBVXsiVyehj1vCaNxDt
GovernorAlpha TH1SVVVU9NF1ans3CRBCJ5kW2yvn4sHP9b
Timelock TRWNvb15NmfNKNLhQpxefFz7cNjrYjEw7x
jumpRateUSDT JumpRateModelV2 TTetZxp98wcPaciyBMHYvQkS735RZ3tyXY
jumpRateUSDJ JumpRateModelV2 TLScd7kpWnKADtH7ZXKzrJHAxJUnjiiExq
jumpRateSUN JumpRateModelV2 TK7WVRz34wUVRCpsgbW1wUCPmh5bSnCqg1
jumpRateWIN JumpRateModelV2 TBtChPo34CGJkb1QVEwPhxS8HQE2Xp7ir2
jumpRateJST JumpRateModelV2 TMNXjQTa8x4wNHBa3X647KRnkRQpSuXBRT
jumpRateWBTT JumpRateModelV2 TJAfCJdJZa44pG5adQGLMLh27hJqPeLxod
jumpRateNFT JumpRateModelV2 TBE9tkWYdZPEHLNeKC6Xn44YFLpieiM3xq.

WhitePaperModelTRX WhitePaperInterestRateModel TF8B4iysAGfrssdQhMJGYsdd9SZoxGsH7M
WhitePaperModelBTC WhitePaperInterestRateModel TYJi9q4qLQWoBiKmMQY3Mn81tmhw7SeCmh

CEther TE2RzoSV3wFK99w6J9UnnZ4vLfXYoxvRwP
usdt CErc20Delegate TLjn59xNM7VEK6VZ3VQ8Y1ipxsdsFka5wZ
usdt CErc20Delegator TXJgMdjVX5dKiQaUi9QobwNxtSQaFqccvd
usdj CErc20Delegate TYSHTEq9NFSgst94saeRvt6rAYgWkqMFbj
usdj CErc20Delegator TL5x9MtSnDy537FXKx53yAaHRRNdg9TkkA
sunold CErc20Delegate TSCpzKvJfXHj1HW5jKg9dZA8z9aMxxGLd8
sunold CErc20Delegator TGBr8uh9jBVHJhhkwSJvQN2ZAKzVkxDmno
win CErc20Delegate TW3GyD3hYkKwzSGytWwWGXpe2a93zCpRzJ
win CErc20Delegator TRg6MnpsFXc82ymUPgf5qbj59ibxiEDWvv
btc CErc20Delegate TVsKSRgRoMcCp798qqRGesXRfzy2MzRjkR
btc CErc20Delegator TLeEu311Cbw63BcmMHDgDLu7fnk9fqGcqT
jst CErc20Delegate TQ2sbnmxtR7jrNk4nxz2A8f9sneCqmk6SB
jst CErc20Delegator TWQhCXaWz4eHK4Kd1ErSDHjMFPoPc9czts
wbtt CErc20Delegate TV4WWBqBfn1kd4KmpYeSJpVAfybfrxEN9L
wbtt CErc20Delegator TUY54PVeH6WCcYCd6ZXXoBDsHytN9V5PXt
nft CErc20Delegate TLkUdtDBLMfJdXni2iTa4u2DKM53XmDJHi.
nft CErc20Delegator TFpPyDCKvNFgos3g3WVsAqMrdqhB81JXHE.
sunnew CErc20Delegator TPXDpkg9e3eZzxqxAUyke9S4z4pGJBJw9e
sunnew CErc20Delegate  TM82erAZJSP7NKc17JdTnzVC8WKJHismWB
tusd  CErc20Delegator  TSXv71Fy5XdL3Rh2QfBoUu3NAaM4sMif8R
tusd CErc20Delegate    THbrSjDsDA2KJRxx8K73tN7vLgaXSUNQFk
usdc CErc20Delegator TNSBA6KvSvMoTqQcEgpVK7VhHT3z7wifxy
usdc CErc20Delegate THQY8YX19jLFSFg1xhthM5wb7xZvKLCzgq
eth CErc20Delegator TR7BUFRQeq1w5jAZf1FKx85SHuX6PfMqsV
eth CErc20Delegate TQBvTVisiceDvsQVbLbcYyWQGWP7wtaQnc
oracle PriceOracle TD8bq1aFY8yc9nsD2rfqqJGDtkh7aPpEpr
oracle proxy PriceOracleProxy TCKp2AzuhzV4B4Ahx1ej4mvQgHZ1kH7F7k
```


Discussion
----------

For any concerns with the protocol, open an issue or visit us on [Telegram](https://t.me/officialjustlend) to discuss.

For security concerns, please email [services@justlend.org](mailto:service@justlend.org).

_© Copyright 2021 JustLend DAO
