// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Voting {
    error AlreadyVoted();
    struct Voter{
        bool hasVoted;
        uint choice;
    }

    mapping(address => Voter) private voters;

    function registerVote(uint _choiceID) public {
        Voter storage voter = voters[msg.sender];
        
        if (voter.hasVoted == true) {
            revert AlreadyVoted();
        }
        
        voter.choice = _choiceID;
        voter.hasVoted = true;

    }
    function getVoterStatus(address _voter) public view returns(bool _hasVoted, uint _choice){
        Voter memory voter = voters[_voter];
        _hasVoted = voter.hasVoted;
        _choice = voter.choice;
    }   
}