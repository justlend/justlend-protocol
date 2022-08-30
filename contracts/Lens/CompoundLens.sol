pragma solidity ^0.5.12;
pragma experimental ABIEncoderV2;

import "../CErc20.sol";
import "../CToken.sol";
import "../PriceOracle.sol";
import "../EIP20Interface.sol";
import "../Governance/GovernorAlpha.sol";
import "../Governance/Comp.sol";

interface ComptrollerLensInterface {
    function markets(address) external view returns (bool, uint);
    function oracle() external view returns (PriceOracle);
    function getAccountLiquidity(address) external view returns (uint, uint, uint);
    function getAssetsIn(address) external view returns (CToken[] memory);
    function claimComp(address) external;
    function compAccrued(address) external view returns (uint);
}

interface IWJST{
    function lockOf(address) external view returns(uint256);
    function lockTo(address,uint256) external view returns(uint256);
}

interface ITRC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract CompoundLens {
    struct CTokenMetadata {
        address cToken;
        uint exchangeRateCurrent;
        uint supplyRatePerBlock;
        uint borrowRatePerBlock;
        uint reserveFactorMantissa;
        uint totalBorrows;
        uint totalReserves;
        uint totalSupply;
        uint totalCash;
        bool isListed;
        uint collateralFactorMantissa;
        address underlyingAssetAddress;
        uint cTokenDecimals;
        uint underlyingDecimals;
    }

    struct tokenInfo{
        uint256 token_balance;
        uint256 token_allowance;
    }

    function cTokenMetadata(address cToken_) public returns (CTokenMetadata memory) {
        CToken cToken=CToken(cToken_);
        uint exchangeRateCurrent = cToken.exchangeRateCurrent();
        ComptrollerLensInterface comptroller = ComptrollerLensInterface(address(cToken.comptroller()));
        (bool isListed, uint collateralFactorMantissa) = comptroller.markets(address(cToken));
        address underlyingAssetAddress;
        uint underlyingDecimals;

        if (compareStrings(cToken.symbol(), "cETH")) {
            underlyingAssetAddress = address(0);
            underlyingDecimals = 18;
        } else {
            CErc20 cErc20 = CErc20(address(cToken));
            underlyingAssetAddress = cErc20.underlying();
            underlyingDecimals = EIP20Interface(cErc20.underlying()).decimals();
        }

        return CTokenMetadata({
            cToken: address(cToken),
            exchangeRateCurrent: exchangeRateCurrent,
            supplyRatePerBlock: cToken.supplyRatePerBlock(),
            borrowRatePerBlock: cToken.borrowRatePerBlock(),
            reserveFactorMantissa: cToken.reserveFactorMantissa(),
            totalBorrows: cToken.totalBorrows(),
            totalReserves: cToken.totalReserves(),
            totalSupply: cToken.totalSupply(),
            totalCash: cToken.getCash(),
            isListed: isListed,
            collateralFactorMantissa: collateralFactorMantissa,
            underlyingAssetAddress: underlyingAssetAddress,
            cTokenDecimals: cToken.decimals(),
            underlyingDecimals: underlyingDecimals
        });
    }

    function cTokenMetadataAll(address[] calldata cTokens) external returns (CTokenMetadata[] memory) {
        uint cTokenCount = cTokens.length;
        CTokenMetadata[] memory res = new CTokenMetadata[](cTokenCount);
        for (uint i = 0; i < cTokenCount; i++) {
            res[i] = cTokenMetadata(cTokens[i]);
        }
        return res;
    }

    struct CTokenBalances {
        address cToken;
        uint balanceOf;
        uint borrowBalanceCurrent;
        uint balanceOfUnderlying;
        uint tokenBalance;
        uint tokenAllowance;
    }

    function cTokenBalances(address cToken_, address payable account) public returns (CTokenBalances memory) {
        CToken cToken=CToken(cToken_);
        uint balanceOf = cToken.balanceOf(account);
        uint borrowBalanceCurrent = cToken.borrowBalanceCurrent(account);
        uint balanceOfUnderlying = cToken.balanceOfUnderlying(account);
        uint tokenBalance;
        uint tokenAllowance;

        if (compareStrings(cToken.symbol(), "cETH")) {
            tokenBalance = account.balance;
            tokenAllowance = account.balance;
        } else {
            CErc20 cErc20 = CErc20(address(cToken));
            EIP20Interface underlying = EIP20Interface(cErc20.underlying());
            tokenBalance = underlying.balanceOf(account);
            tokenAllowance = underlying.allowance(account, address(cToken));
        }

        return CTokenBalances({
            cToken: address(cToken),
            balanceOf: balanceOf,
            borrowBalanceCurrent: borrowBalanceCurrent,
            balanceOfUnderlying: balanceOfUnderlying,
            tokenBalance: tokenBalance,
            tokenAllowance: tokenAllowance
        });
    }

    function cTokenBalancesAll(address[] calldata cTokens, address payable account) external returns (CTokenBalances[] memory) {
        uint cTokenCount = cTokens.length;
        CTokenBalances[] memory res = new CTokenBalances[](cTokenCount);
        for (uint i = 0; i < cTokenCount; i++) {
            res[i] = cTokenBalances(cTokens[i], account);
        }
        return res;
    }

    struct CTokenUnderlyingPrice {
        address cToken;
        uint underlyingPrice;
    }

    function cTokenUnderlyingPrice(address cToken_) public returns (CTokenUnderlyingPrice memory) {
        CToken cToken=CToken(cToken_);
        ComptrollerLensInterface comptroller = ComptrollerLensInterface(address(cToken.comptroller()));
        PriceOracle priceOracle = comptroller.oracle();

        return CTokenUnderlyingPrice({
            cToken: address(cToken),
            underlyingPrice: priceOracle.getUnderlyingPrice(cToken)
        });
    }

    function cTokenUnderlyingPriceAll(address[] calldata cTokens) external returns (CTokenUnderlyingPrice[] memory) {
        uint cTokenCount = cTokens.length;
        CTokenUnderlyingPrice[] memory res = new CTokenUnderlyingPrice[](cTokenCount);
        for (uint i = 0; i < cTokenCount; i++) {
            res[i] = cTokenUnderlyingPrice(cTokens[i]);
        }
        return res;
    }

    struct AccountLimits {
        CToken[] markets;
        uint liquidity;
        uint shortfall;
    }

    function getAccountLimits(address comptroller_, address account) public returns (AccountLimits memory) {
        ComptrollerLensInterface comptroller=ComptrollerLensInterface(comptroller_);
        (uint errorCode, uint liquidity, uint shortfall) = comptroller.getAccountLiquidity(account);
        require(errorCode == 0);

        return AccountLimits({
            markets: comptroller.getAssetsIn(account),
            liquidity: liquidity,
            shortfall: shortfall
        });
    }

    struct GovReceipt {
        uint proposalId;
        bool hasVoted;
        bool support;
        uint96 votes;
    }

    function getGovReceipts(address governor_, address voter, uint[] memory proposalIds) public view returns (GovReceipt[] memory) {
        GovernorAlpha governor=GovernorAlpha(governor_);
        uint proposalCount = proposalIds.length;
        GovReceipt[] memory res = new GovReceipt[](proposalCount);
        for (uint i = 0; i < proposalCount; i++) {
            GovernorAlpha.Receipt memory receipt = governor.getReceipt(proposalIds[i], voter);
            res[i] = GovReceipt({
                proposalId: proposalIds[i],
                hasVoted: receipt.hasVoted,
                support: receipt.support,
                votes: receipt.votes
            });
        }
        return res;
    }

    struct GovProposal {
        uint proposalId;
        address proposer;
        uint eta;
        address[] targets;
        uint[] values;
        string[] signatures;
        bytes[] calldatas;
        uint startBlock;
        uint endBlock;
        uint forVotes;
        uint againstVotes;
        bool canceled;
        bool executed;
    }

    function setProposal(GovProposal memory res, address governor_, uint proposalId) internal view {
        GovernorAlpha governor=GovernorAlpha(governor_);
        (
            ,
            address proposer,
            uint eta,
            uint startBlock,
            uint endBlock,
            uint forVotes,
            uint againstVotes,
            bool canceled,
            bool executed
        ) = governor.proposals(proposalId);
        res.proposalId = proposalId;
        res.proposer = proposer;
        res.eta = eta;
        res.startBlock = startBlock;
        res.endBlock = endBlock;
        res.forVotes = forVotes;
        res.againstVotes = againstVotes;
        res.canceled = canceled;
        res.executed = executed;
    }

    function getGovProposals(address governor_, uint[] calldata proposalIds) external view returns (GovProposal[] memory) {
        GovernorAlpha governor=GovernorAlpha(governor_);
        GovProposal[] memory res = new GovProposal[](proposalIds.length);
        for (uint i = 0; i < proposalIds.length; i++) {
            (
                address[] memory targets,
                uint[] memory values,
                string[] memory signatures,
                bytes[] memory calldatas
            ) = governor.getActions(proposalIds[i]);
            res[i] = GovProposal({
                proposalId: 0,
                proposer: address(0),
                eta: 0,
                targets: targets,
                values: values,
                signatures: signatures,
                calldatas: calldatas,
                startBlock: 0,
                endBlock: 0,
                forVotes: 0,
                againstVotes: 0,
                canceled: false,
                executed: false
            });
            setProposal(res[i], governor_, proposalIds[i]);
        }
        return res;
    }

    struct CompBalanceMetadata {
        uint balance;
        uint votes;
        address delegate;
    }

    function getCompBalanceMetadata(address comp_, address account) external view returns (CompBalanceMetadata memory) {
        Comp comp=Comp(comp_);
        return CompBalanceMetadata({
            balance: comp.balanceOf(account),
            votes: uint256(comp.getCurrentVotes(account)),
            delegate: comp.delegates(account)
        });
    }

    struct CompBalanceMetadataExt {
        uint balance;
        uint votes;
        address delegate;
        uint allocated;
    }

    function getCompBalanceMetadataExt(address comp_, address comptroller_, address account) external returns (CompBalanceMetadataExt memory) {
        Comp comp = Comp(comp_);
        ComptrollerLensInterface comptroller = ComptrollerLensInterface(comptroller_);
        uint balance = comp.balanceOf(account);
        comptroller.claimComp(account);
        uint newBalance = comp.balanceOf(account);
        uint accrued = comptroller.compAccrued(account);
        uint total = add(accrued, newBalance, "sum comp total");
        uint allocated = sub(total, balance, "sub allocated");

        return CompBalanceMetadataExt({
            balance: balance,
            votes: uint256(comp.getCurrentVotes(account)),
            delegate: comp.delegates(account),
            allocated: allocated
        });
    }

    struct CompVotes {
        uint blockNumber;
        uint votes;
    }

    function getCompVotes(address comp_, address account, uint32[] calldata blockNumbers) external view returns (CompVotes[] memory) {
        Comp comp = Comp(comp_);
        CompVotes[] memory res = new CompVotes[](blockNumbers.length);
        for (uint i = 0; i < blockNumbers.length; i++) {
            res[i] = CompVotes({
                blockNumber: uint256(blockNumbers[i]),
                votes: uint256(comp.getPriorVotes(account, blockNumbers[i]))
            });
        }
        return res;
    }

    function getVoteInfo(address _user,address _jst,address _wjst) public view returns(uint256 jstBalance,uint256 surplusVotes,uint256 totalVote,uint256 castVote){
        jstBalance = ITRC20(_jst).balanceOf(_user);//jst余额
        surplusVotes = ITRC20(_wjst).balanceOf(_user);//剩余选票
        castVote = IWJST(_wjst).lockOf(_user);//已投选票
        totalVote = add(surplusVotes,castVote,"sum vote total");//选票总数
    }

    function getBalanceAndApprove(address _user , address[] memory _tokens , address[] memory _pools) public view returns(uint256[] memory info, uint256[] memory _allowance){
        uint256 _tokenCount = _tokens.length;
        require(_tokenCount == _pools.length,'array length not matched');
        info = new uint256[](_tokenCount);
        _allowance = new uint256[](_tokenCount);
        for(uint256 i = 0; i < _tokenCount; i++){
            uint256 token_amount = 0;
            uint256 token_allowance = 0;
            if(address(0) == _tokens[i]){
                token_amount = address(_user).balance;
                token_allowance = uint256(-1);
            }else{
                ( bool success, bytes memory data) = _tokens[i].staticcall(abi.encodeWithSelector(0x70a08231, _user));
                success;
                token_amount = 0;
                if(data.length != 0){
                    token_amount = abi.decode(data,(uint256));
                }
                token_allowance = ITRC20(_tokens[i]).allowance(_user,address(_pools[i]));
            }
            info[i] = uint256(token_amount);
            _allowance[i] = uint256(token_allowance);
        }
    }

    function getBalanceAndApprove2(address _user , address[] memory _tokens , address[] memory _pools) public view returns(tokenInfo[] memory info){
        uint256 _tokenCount = _tokens.length;
        require(_tokenCount == _pools.length,'array length not matched');
        info = new tokenInfo[](_tokenCount);
        for(uint256 i = 0; i < _tokenCount; i++){
            uint256 token_amount = 0;
            uint256 token_allowance = 0;
            if(address(0) == _tokens[i]){
                token_amount = address(_user).balance;
                token_allowance = uint256(-1);
            }else{
                ( bool success, bytes memory data) = _tokens[i].staticcall(abi.encodeWithSelector(0x70a08231, _user));
                success;
                token_amount = 0;
                if(data.length != 0){
                    token_amount = abi.decode(data,(uint256));
                }
                token_allowance = ITRC20(_tokens[i]).allowance(_user,address(_pools[i]));
            }
            info[i] = tokenInfo(token_amount,token_allowance);
        }
    }

    function getBalance(address _user , address[] memory _tokens) public view returns(uint256[] memory info){
        uint256 _tokenCount = _tokens.length;
        info = new uint256[](_tokenCount);
        for(uint256 i = 0; i < _tokenCount; i++){
            uint256 token_amount = 0;
            if(address(0) == _tokens[i]){
                token_amount = address(_user).balance;
            }else{
                ( bool success, bytes memory data) = _tokens[i].staticcall(abi.encodeWithSelector(0x70a08231, _user));
                success;
                token_amount = 0;
                if(data.length != 0){
                    token_amount = abi.decode(data,(uint256));
                }
            }
            info[i] = uint256(token_amount);
        }
    }

    function getAllowance(address _user , address[] memory _tokens) public view returns(uint256[] memory _allowance){
        uint256 _tokenCount = _tokens.length;
        _allowance = new uint256[](_tokenCount);
        for(uint256 i = 0; i < _tokenCount; i++){
            uint256 token_allowance = 0;
            ( , bytes memory data) = _tokens[i].staticcall(abi.encodeWithSelector(0xdd62ed3e,_user,address(_tokens[i])));
            if(data.length != 0){
                    token_allowance = abi.decode(data,(uint256));
                }

            // token_allowance = ITRC20(_tokens[i]).allowance(_user,address(_tokens[i]));
            _allowance[i] = uint256(token_allowance);
        }
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function add(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;
        return c;
    }
}
