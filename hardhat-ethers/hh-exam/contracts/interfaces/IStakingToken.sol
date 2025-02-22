// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStakingToken is IERC20 {
    function decimals() external view returns (uint8);
    function mint(address to, uint256 amount) external;
}
