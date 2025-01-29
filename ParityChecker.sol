// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;


library NumLib {
    function isEven(uint256 number) external pure returns ( bool ) {
        if (number % 2 == 0) {
            return true;
        }
        return false;
    }
}

contract ParityChecker {
    function checkParity(uint256 _number) public pure returns ( bool ) {
       if (NumLib.isEven(_number)) {
            return true;
       }
       return false;
    }
}