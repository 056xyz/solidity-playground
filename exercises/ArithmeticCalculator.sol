// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Calculator {

    function add (int256 x, int256 y) public pure returns(int256 result) {
        result = x + y;
    }
    function subtract (int256 x, int256 y) public pure returns(int256 result) {
        result = x - y;

    }
    function multiply (int256 x, int256 y) public pure returns(int256 result) {
        result = x * y;

    }
    function divide (int256 x, int256 y) public pure returns(int256 result) {
        require(y != 0, "y is 0");
        result = x / y;
    }
}