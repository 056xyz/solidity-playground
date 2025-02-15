// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract tempConverter{

    function toFahrenheit(int256 _tempToConvert) public pure returns(int256 convertedTemp){
        convertedTemp = (_tempToConvert * 9/5) + 32;

    }
    function toCelsius(int256 _tempToConvert) public pure returns(int256 convertedTemp){
        convertedTemp = (_tempToConvert - 32 ) * 5/9;
    }
}