// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForceFeed {
    // Vulnerable
    function isNotStarted() public view returns (bool) {
        return address(this).balance == 0;
    }

    uint256 public deposits;

    function deposit() external payable {
        deposits += msg.value;
    }

    // More robust
    function isNotStartedRobust() public view returns (bool) {
        return deposits == 0;
    }
}

contract Attacker {
    function attack(address payable forceFeed) external {
        selfdestruct(forceFeed);
    }

    receive() external payable {}
}