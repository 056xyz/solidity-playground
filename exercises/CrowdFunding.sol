// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract CrowdFunding {
    uint constant GOAL_AMOUNT = 10000;
    uint constant endTime = 60;
    uint totalAmountContributed;
    uint startTime;

    mapping(address => uint) public contributions;

    constructor(){
        startTime = block.timestamp;
    }

    function contribute(uint _contribution) external {

        totalAmountContributed += _contribution;
    }
    function checkGoalReached() public view returns(bool){
        uint currTime = block.timestamp;
        if ( totalAmountContributed >= GOAL_AMOUNT && startTime + endTime >= currTime) return true;
        return false;
    }
    function withdraw() public {
        if (checkGoalReached()) {
            uint contributed = contributions[msg.sender];
            contributions[msg.sender] = 0;
            totalAmountContributed -= contributed;
        } else {
            revert("testing");
        }
    }
}