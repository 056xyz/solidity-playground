// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract BillSplitter{
    error InvalidSplit();
    function splitExpense(uint totalAmount, uint numPeople) public pure returns(uint split) {
       split =  totalAmount / numPeople;

       if (split * numPeople == totalAmount) {
        return split;
       } else {
        revert InvalidSplit();
       }
    }
}