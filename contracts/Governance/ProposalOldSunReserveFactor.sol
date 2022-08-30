pragma solidity ^0.5.12;
pragma experimental ABIEncoderV2;

import "../SafeMath.sol";

interface GovernorAlphaInterface {
    struct Proposal {
        mapping(address => Receipt) receipts;
    }

    struct Receipt {
        bool hasVoted;
        bool support;
        uint96 votes;
    }

    function state(uint proposalId) external view returns (uint8);

    function getReceipt(uint proposalId, address voter) external view returns (Receipt memory);

    function propose(address[] calldata targets, uint[] calldata values, string[] calldata signatures, bytes[] calldata calldatas, string calldata description) external returns (uint);
}

interface IWJST {
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

contract ProposalOldSunReserveFactor {
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

    event OwnershipTransferred(address  indexed previousOwner, address  indexed newOwner);
    event Withdraw_token(address _caller, address _recievor, uint256 _amount);

    function() external payable {
    }

    constructor(address governorAlpha_, address jst_, address wjst_, address newOwner_) public{
        governorAlpha = GovernorAlphaInterface(governorAlpha_);
        _owner = newOwner_;
        jstAddress = jst_;
        wjstAddress = wjst_;
    }

    modifier  onlyOwner()  {
        require(msg.sender == _owner);
        _;
    }

    modifier  onlyCFO()  {
        require(msg.sender == _cfo);
        _;
    }

    function createPropose() public returns (bool){
        require(onlyOnce == false, "onlyOnce");
        uint256 balance = ITRC20(jstAddress).balanceOf(address(this));
        if (balance > 200000000e18) {
            ITRC20(jstAddress).approve(wjstAddress, balance);
            IWJST(wjstAddress).deposit(balance);
            _createPropose();
            onlyOnce = true;
            return true;
        }
        return false;
    }

    function _createPropose() internal {
        address[] memory targets = new address[](1);
        //mainnet jOLDSUN 0x4434BECA3Ac7D96E2b4eeF1974CF9bDdCb7A328B TGBr8uh9jBVHJhhkwSJvQN2ZAKzVkxDmno
        //nile jOLDSUN 0xB6c0b3189aE3D5775eC09Ac939041a3813A814eC TSdWpyV2Z8YdJmsLcwX3udZTTafohxZcVJ

        targets[0] = (0x4434BECA3Ac7D96E2b4eeF1974CF9bDdCb7A328B);

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        string[] memory signatures = new string[](1);
        signatures[0] = ("_setReserveFactor(uint256)");

        bytes[] memory calldatas = new bytes[](1);
        // nile Delegator sunold :0xB6c0b3189aE3D5775eC09Ac939041a3813A814eC
        calldatas[0] = abi.encode(1e18);

        string memory description = "set jSUNOLD _setReserveFactor";
        governorAlpha.propose(targets, values, signatures, calldatas, description);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
        emit  OwnershipTransferred(_owner, newOwner);
    }

    function withdrawToken() public onlyOwner {
        _withdrawToken();
    }

    function withdrawTokenCFO() public onlyCFO {
        _withdrawToken();
    }

    function _withdrawToken() internal {
        uint256 wjstAmount = ITRC20(wjstAddress).balanceOf(address(this));
        if (wjstAmount > 0) {
            IWJST(wjstAddress).withdraw(wjstAmount);
        }
        uint256 jstAmount = ITRC20(jstAddress).balanceOf(address(this));
        if (jstAmount > 0) {
            ITRC20(jstAddress).transfer(_owner, jstAmount);
        }
        if (address(this).balance > 0) {
            address(uint160(_owner)).transfer(address(this).balance);
        }
        emit Withdraw_token(msg.sender, _owner, jstAmount);
    }

}


