// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import { IStakingToken } from "./interfaces/IStakingToken.sol";

    struct StakerData {
        uint256 stakedAmount;
        uint256 rewardAmount;
        uint256 stakingStartTime;
    }

    error InsufficientBalance();
    error CannotBeZero();
    error NotAStaker();
    error CannotUnStakeYet();
    
    event Staked(address indexed staker, uint256 amount);
    event UnStaked(address indexed staker, uint256 amount);
    event RewardClaimed(address indexed staker, uint256 amount);
    event RewardUpdated(address indexed staker, uint256 newReward);

contract StakingPool {
    
    uint256 private constant RATE_PER_YEAR = 500;
    uint256 private constant BPS = 10000;
    uint256 private constant YEAR_IN_SECS = 365 days;
    // uint256 private constant MIN_STAKING_DURATION = 1 days;
    uint256 private constant MIN_STAKING_DURATION = 60; // 1m in case needs to be tested manually 
    address payable immutable stx;

    mapping(address staker => StakerData info) public stakers;
    modifier MustBeMoreThanZero(uint256 value){
        if(value == 0) {
            revert CannotBeZero();
        }
        _;
    }
    constructor(address payable _stx) {
        stx = _stx;
    }

    function stake(uint256 _amount) external MustBeMoreThanZero(_amount){
        IStakingToken(stx).transferFrom(msg.sender, address(this), _amount);

        StakerData storage staker = stakers[msg.sender];
        staker.stakedAmount += _amount;
        staker.stakingStartTime = block.timestamp;

        _updateRewards();
        
        emit Staked(msg.sender, _amount);
    }

    function unStake(uint256 _amount) external MustBeMoreThanZero(_amount){
        StakerData storage staker = stakers[msg.sender];

        if (_amount > staker.stakedAmount) {
            revert InsufficientBalance();
        }

        if (block.timestamp < staker.stakingStartTime + MIN_STAKING_DURATION) {
            revert CannotUnStakeYet();
        }

        _updateRewards();

        stakers[msg.sender].stakedAmount -= _amount;
        staker.stakingStartTime = block.timestamp;
        
        IStakingToken(stx).transfer(msg.sender, _amount);

        emit UnStaked(msg.sender, _amount);
    }

    function claimRewards() external {
        _updateRewards();

        StakerData storage staker = stakers[msg.sender];
        uint256 reward = staker.rewardAmount;
        staker.rewardAmount = 0;
        
        IStakingToken(stx).mint(msg.sender, reward);
        
        emit RewardClaimed(msg.sender, reward);
    }

    function _updateRewards() private {
        StakerData storage staker = stakers[msg.sender];
        if (staker.stakingStartTime == 0 || staker.stakedAmount == 0) {
            revert NotAStaker();
        }
        uint256 timeElapsed = block.timestamp - staker.stakingStartTime;
        
        uint256 reward = (staker.stakedAmount * timeElapsed * RATE_PER_YEAR) / (YEAR_IN_SECS * BPS);
        staker.rewardAmount += reward;

        emit RewardUpdated(msg.sender, reward);
    }

    function getStakedBalance(address _staker) external view returns (uint256) {
        return stakers[_staker].stakedAmount;
    }
}