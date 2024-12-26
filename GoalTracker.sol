// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract GoalTracker {

    error AlreadyClaimed();
    error InsufficientAmount();

    uint constant GOAL = 1000;
    uint constant BASE_REWARD = 50;

    mapping(address => uint) public userSpending;
    mapping(address => bool) public claimedRewards;

    function spend(uint amount)public {
        if (claimedRewards[msg.sender] == true) {
            revert AlreadyClaimed();
        }

        userSpending[msg.sender] += amount;
    }

    function claimReward()public returns(uint reward) {
        if (claimedRewards[msg.sender] == true) {
            revert AlreadyClaimed();
        }

        if (userSpending[msg.sender] < GOAL) {
            revert InsufficientAmount();
        }

        for (uint i = 0; i < 5; i++) {
            reward += BASE_REWARD;
        }

        userSpending[msg.sender] = 0;
        claimedRewards[msg.sender] = true;
    }
}