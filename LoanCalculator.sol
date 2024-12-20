// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract LoanCalculator {
    error InvalidIR();
    error InvalidPeriod();

    function calculateTotalPayable(uint256 principal, uint256 ir, uint256 period)
        public
        pure
        returns (uint256 amountPayable)
    {
        if (ir > 100) {
            revert InvalidIR();
        }
        if (period < 1) {
            revert InvalidPeriod();
        }

        amountPayable = principal + (principal * ir * period / 100);
    }
}
