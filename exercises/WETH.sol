// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {
    event Deposit(address indexed account, uint amount)
    event Withdraw(address indexed account, uint amount)
    constructor()ERC20("Wrapped ETH", "WETH", 18){}
    fallback() external payable {
        deposit();
    }

    function deposit() public payable{
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value)
    }
    function withdraw(uint _amount){
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount)
    }
}