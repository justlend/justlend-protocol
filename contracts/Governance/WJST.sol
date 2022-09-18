pragma solidity ^0.5.12;
pragma experimental ABIEncoderV2;

import "../SafeMath.sol";

interface GovernorAlphaInterface {

    function state(uint proposalId) external view returns (uint8);
}

contract TRC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract TRC20 is TRC20Events {
    function totalSupply() public view returns (uint256);

    function balanceOf(address guy) public view returns (uint256);

    function allowance(address src, address guy) public view returns (uint256);

    function approve(address guy, uint256 wad) public returns (bool);

    function transfer(address dst, uint256 wad) public returns (bool);

    function transferFrom(
        address src, address dst, uint256 wad
    ) public returns (bool);
}

contract ITokenDeposit is TRC20 {
    function deposit(uint256) public;

    function withdraw(uint256) public;
}

contract WJST is ITokenDeposit {
    using SafeMath for uint256;
    string public name = "Wrapped JST";
    string public symbol = "WJST";
    uint8  public decimals = 18;
    uint256 internal totalSupply_;
    uint256 internal totalLocked_;
    address public _owner;
    address public jstAddress;

    GovernorAlphaInterface public governorAlpha;

    event  Approval(address indexed src, address indexed guy, uint256 sad);
    event  Transfer(address indexed src, address indexed dst, uint256 sad);
    event  Deposit(address indexed dst, uint256 sad);
    event  Withdrawal(address indexed src, uint256 sad);

    event  VoteAndLock(address indexed src, uint256 indexed proposalId, uint8 support, uint256 sad);
    event  WithdrawVote(address indexed src, uint256 indexed proposalId, uint256 sad);

    event  OwnershipTransferred(address  indexed previousOwner, address  indexed newOwner);

    mapping(address => uint256)                      private  balanceOf_;
    mapping(address => mapping(address => uint256))  private  allowance_;
    mapping(address => uint256)                      private  lockOf_;
    mapping(address => mapping(uint256 => uint256))  private  lockTo_;

    constructor(address governorAlpha_, address jst_) public {
        governorAlpha = GovernorAlphaInterface(governorAlpha_);
        _owner = msg.sender;
        jstAddress = jst_;
    }

    modifier  onlyOwner()  {
        require(msg.sender == _owner);
        _;
    }

    function deposit(uint256 sad) public {
        require(TRC20(jstAddress).transferFrom(msg.sender, address(this), sad));
        balanceOf_[msg.sender] = balanceOf_[msg.sender].add(sad);
        totalSupply_ = totalSupply_.add(sad);
        emit Transfer(address(0), msg.sender, sad);
        emit Deposit(msg.sender, sad);
    }

    function withdraw(uint sad) public {
        require(balanceOf_[msg.sender] >= sad, "not enough balance");
        balanceOf_[msg.sender] -= sad;
        totalSupply_ -= sad;
        require(TRC20(jstAddress).transfer(msg.sender, sad));
        emit Transfer(msg.sender, address(0), sad);
        emit Withdrawal(msg.sender, sad);
    }

    function getPriorVotes(address account, uint256 blockNumber) public view returns (uint256){
        blockNumber;
        return balanceOf_[account];
    }

    function voteFresh(address account, uint256 proposalId, uint8 support, uint256 value) public returns (bool success){
        require(msg.sender == address(governorAlpha), "only governorAlpha can be called");
        require(account != address(0), "account exception");
        totalSupply_ = totalSupply_.sub(value);
        totalLocked_ = totalLocked_.add(value);
        balanceOf_[account] = balanceOf_[account].sub(value);
        lockOf_[account] = lockOf_[account].add(value);
        lockTo_[account][proposalId] = lockTo_[account][proposalId].add(value);
        emit Transfer(account, address(0), value);
        emit VoteAndLock(account, proposalId, support, value);
        return true;
    }

    function withdrawVotes(uint256 proposalId) public {
        require(governorAlpha.state(proposalId) >= 2, "proposal state mismatch");
        withdrawVotesFresh(msg.sender, proposalId);
    }

    function withdrawVotesFresh(address account, uint256 proposalId) internal returns (bool success){
        uint256 value = lockTo_[account][proposalId];
        totalSupply_ = totalSupply_.add(value);
        totalLocked_ = totalLocked_.sub(value);
        balanceOf_[account] = balanceOf_[account].add(value);
        lockOf_[account] = lockOf_[account].sub(value);
        lockTo_[account][proposalId] = 0;
        emit Transfer(address(0), account, value);
        emit WithdrawVote(account, proposalId, value);
        return true;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function totalLocked() public view returns (uint256) {
        return totalLocked_;
    }

    function balanceOf(address guy) public view returns (uint256){
        return balanceOf_[guy];
    }

    function lockOf(address guy) public view returns (uint256){
        return lockOf_[guy];
    }

    function allowance(address src, address guy) public view returns (uint256){
        return allowance_[src][guy];
    }

    function lockTo(address guy, uint256 proposalId) public view returns (uint256){
        return lockTo_[guy][proposalId];
    }

    function approve(address guy, uint256 sad) public returns (bool) {
        allowance_[msg.sender][guy] = sad;
        emit Approval(msg.sender, guy, sad);
        return true;
    }

    function approve(address guy) public returns (bool) {
        return approve(guy, uint256(- 1));
    }

    function transfer(address dst, uint256 sad) public returns (bool) {
        return transferFrom(msg.sender, dst, sad);
    }

    function transferFrom(address src, address dst, uint256 sad)
    public
    returns (bool)
    {
        require(balanceOf_[src] >= sad, "src balance not enough");

        if (src != msg.sender && allowance_[src][msg.sender] != uint256(- 1)) {
            require(allowance_[src][msg.sender] >= sad, "src allowance is not enough");
            allowance_[src][msg.sender] -= sad;
        }

        balanceOf_[src] -= sad;
        balanceOf_[dst] += sad;

        emit Transfer(src, dst, sad);

        return true;
    }

    function setGovernorAlpha(address governorAlpha_) public onlyOwner {
        governorAlpha = GovernorAlphaInterface(governorAlpha_);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit  OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

