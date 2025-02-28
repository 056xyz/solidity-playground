// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./IERC20.sol";

contract StakingRewards {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;

    address public owner;

    uint public duration;
    uint public finishAt;
    uint public updatedAt;
    uint public rewardRate;
    uint public rewardPerTokenStored;
    mapping(address => uint) public userRewardsPerTokenPaid;
    mapping(address => uint) public rewards;

    uint public totalSupply;
    mapping(address=> uint) public balanceOf;

    constructor(address _stakingToken, address _rewardsToken) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken= IERC20(_rewardsToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'You are not the owner');
        _;
    }

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();
        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardsPerTokenPaid[_account] = rewardPerTokenStored;    
        }
        _;
    }

    function setRewardDuration(uint _duration) external onlyOwner {
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }

    function notifyRewardAmount(uint _amount) external onlyOwner updateReward(address(0)) {
        if (block.timestamp > finishAt) {
            rewardRate = _amount / duration;
        } else {
            uint remainingRewards = rewardRate * (finishAt - block.timestamp);
            rewardRate = (remainingRewards + _amount) / duration;
        }

        require(rewardRate > 0, "reward rate = 0");
        require(rewardRate * duration <= rewardsToken.balanceOf(address(this)));

        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;
    }
    function stake(uint _amount) external updateReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;
    }
    function withdraw(uint _amount) external updateReward(msg.sender){
        require(_amount > 0, "amount = 0");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        stakingToken.transfer(msg.sender, _amount);
    }

    function lastTimeRewardApplicable() public view returns (uint) {
        return _min(block.timestamp, finishAt);
    }

    function rewardPerToken() public view returns ( uint ) { 
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }

        return rewardPerTokenStored + (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) / totalSupply;
    }

    function _min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function earned(address _account) public view returns (uint) {
         return (balanceOf[_account] * (rewardPerToken() - userRewardsPerTokenPaid[_account]) / 1e18) + rewards[_account];
    }
    function getReward() external {
        uint reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }
 
}