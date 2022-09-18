pragma solidity ^0.5.12;
pragma experimental ABIEncoderV2;

import "../SafeMath.sol";

interface GovernorAlphaInterface{
    struct Proposal {
        mapping (address => Receipt) receipts;
    }
    struct Receipt {
        bool hasVoted;
        bool support;
        uint96 votes;
    }
    function state(uint proposalId) external view returns (uint8);
    function getReceipt(uint proposalId, address voter) external view returns(Receipt memory);
    function propose(address[] calldata targets, uint[] calldata values, string[] calldata signatures, bytes[] calldata calldatas, string calldata description) external returns (uint) ;
}

interface IWJST{
    function deposit(uint256) external;
    function withdraw(uint256) external;
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

contract ProposalAddTusdMarket {
    using SafeMath for uint256;

    address public _owner;
    address public _cfo = msg.sender;
    address public jstAddress;
    address public wjstAddress;
    bool public onlyOnce = false;

    GovernorAlphaInterface public governorAlpha;
    struct Receipt {
        bool hasVoted;
        bool support;
        uint96 votes;
    }

    event OwnershipTransferred(address  indexed  previousOwner,  address  indexed  newOwner);
    event Withdraw_token(address _caller, address _recievor, uint256 _amount);

    function() external payable {
    }

    constructor(address governorAlpha_, address jst_, address wjst_, address newOwner_ ) public{
        governorAlpha = GovernorAlphaInterface(governorAlpha_);
        _owner = newOwner_;  
        jstAddress = jst_; 
        wjstAddress = wjst_;
    }

    modifier  onlyOwner()  {
        require(msg.sender  ==  _owner);
        _;
    }

    modifier  onlyCFO()  {
        require(msg.sender  ==  _cfo);
        _;
    }

    function createPropose() public returns(bool){
        require(onlyOnce == false,"onlyOnce");
        uint256 balance = ITRC20(jstAddress).balanceOf(address(this));
        if(balance > 200000000e18){
            ITRC20(jstAddress).approve(wjstAddress,balance);
            IWJST(wjstAddress).deposit(balance);
            _createPropose();
            onlyOnce = true;
            return true;
        }
        return false;
    }

    function _createPropose() internal{ 
        address[] memory targets = new address[](2);
        // miannet : TGjYzgCyPobsNS9n6WcbdLVR9dH7mWqFx7   0x4a33BF2666F2e75f3D6Ad3b9ad316685D5C668D4
        //nile: unitroller 合约地址：TPdWn5nRLxx8n2WKbBZ3FkBejVdiTUGDVM 0x95d847d74d6b25B60c293fEb95Fe6f26f89352d8
        targets[0] = (0x4a33BF2666F2e75f3D6Ad3b9ad316685D5C668D4);
        targets[1] = (0x4a33BF2666F2e75f3D6Ad3b9ad316685D5C668D4);

        uint256[] memory values = new uint256[](2);
        values[0] = 0;
        values[1] = 0;

        string[] memory signatures = new string[](2);
        signatures[0] = ("_supportMarket(address)");
        signatures[1] = ("_setCollateralFactor(address,uint256)"); 

        bytes[] memory calldatas = new bytes[](2);
        // nile Delegator tusd :0x223DA1345AB05C950D10FCE729996EF8C61472B6
        calldatas[0] = abi.encode(0xB5B1A24c3067f985ac2da2F6BcE0FA685Bf8eC06); //todo: miannet 0xB5B1A24c3067f985ac2da2F6BcE0FA685Bf8eC06
        calldatas[1] = abi.encode(0xB5B1A24c3067f985ac2da2F6BcE0FA685Bf8eC06,750000000000000000); //todo: miannet 0xB5B1A24c3067f985ac2da2F6BcE0FA685Bf8eC06

        string memory description = "add jTUSD Market";
        governorAlpha.propose(targets,values,signatures,calldatas,description);    
    }

    function  transferOwnership(address newOwner)  public  onlyOwner  {
        require(newOwner  !=  address(0));
        _owner  =  newOwner;
        emit  OwnershipTransferred(_owner,  newOwner);
    }

    function withdrawToken() public onlyOwner {
        _withdrawToken();
    }

    function withdrawTokenCFO() public  onlyCFO {
        _withdrawToken();
    }

    function _withdrawToken() internal {
        uint256 wjstAmount = ITRC20(wjstAddress).balanceOf(address(this));
        if(wjstAmount > 0){
            IWJST(wjstAddress).withdraw(wjstAmount);
        }
        uint256 jstAmount = ITRC20(jstAddress).balanceOf(address(this));
        if(jstAmount > 0){
            ITRC20(jstAddress).transfer(_owner, jstAmount);
        }
        if(address(this).balance > 0){
            address(uint160(_owner)).transfer(address(this).balance);
        }
        emit Withdraw_token(msg.sender,_owner,jstAmount);
    }

}


