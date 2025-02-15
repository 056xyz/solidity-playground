// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract CompundInterestCalculator {
    error InvalidIR();
    error InvalidPeriod();

    function calculateCompoundInterest2(uint256 principal, uint256 rate, uint256 period)
        public
        pure
        returns (uint256)
    {
        if (rate > 100) {
            revert InvalidIR();
        }

        if (period < 1) {
            revert InvalidPeriod();
        }

        uint256 amount = principal;
        for (uint256 i = 0; i < period; i++) {
            amount = amount * (100 + rate) / 100;
        }
        return amount;
    }
}
