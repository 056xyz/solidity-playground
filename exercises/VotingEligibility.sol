// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract VotingEligibility {
    error VotingEligibility__Ineligible();

    function checkEligibility(uint256 age) public pure returns(bool){
        if (age < 18) {
            revert VotingEligibility__Ineligible();
        } else {
             return true;
        }
    }
}