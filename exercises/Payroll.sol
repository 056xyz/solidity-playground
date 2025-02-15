// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Payroll{
    error InvalidValue();
    error InvalidRange();
    function calculatePaycheck(uint salary, uint rating)public pure returns (uint res){
        if (salary < 1) {
            revert InvalidValue();
        }
        if (rating > 10) {
            revert InvalidRange();
        }

        if (rating > 8) {
            res = salary + (salary / 10);
        } else {
            res = salary;
        }

    }
}