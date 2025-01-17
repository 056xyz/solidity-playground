// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "hardhat/console.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SoftCoin is ERC20 {
    constructor() ERC20("SoftCoin", "SOFT") {}

    function mint(address to, uint256 amount) external  {
        _mint(to, amount);
    }
}

interface ISoftCoin {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint value) external returns (uint256);
}

contract UniCoin is ERC20, Ownable(msg.sender) {
    error MustBeMoreThanZero();
    error TransferFailed();

    ISoftCoin public softCoin;
    uint256 public softCoinToUniCoinRate; // 1 SOFT == 1 UNI

    constructor(address _softCoinAddress, uint256 _rate) ERC20("UniCoin", "UNI") {
        softCoin = ISoftCoin(_softCoinAddress);
        softCoinToUniCoinRate = _rate;
    }

    function trade(uint256 softCoinAmount) external {
        if (softCoinAmount <= 0) {
            revert MustBeMoreThanZero();
        }
        softCoin.approve(address(this), softCoinAmount);

        uint256 allowance = softCoin.allowance(msg.sender, address(this));
        require(allowance >= softCoinAmount, "Allowance too low, please approve the transfer");

        uint256 uniCoinAmount = softCoinAmount * softCoinToUniCoinRate;

        bool ok = softCoin.transferFrom(msg.sender, address(this), softCoinAmount);
        if (!ok) {
            revert TransferFailed();
        }

        _mint(msg.sender, uniCoinAmount);
    }

    function setConversionRate(uint256 newRate) external onlyOwner {
        softCoinToUniCoinRate = newRate;
    }
}
