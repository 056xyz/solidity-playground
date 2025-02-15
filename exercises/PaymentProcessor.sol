// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.5.0/contracts/access/AccessControl.sol";
import "hardhat/console.sol";
library PaymentLib {
    error TransferFailed();

    function transferETH(address _self, uint value) internal returns (bool) {
        (bool ok,) = payable(_self).call{value: value}("");
        if (!ok) {
            revert TransferFailed();
        }
        return true;
    }

    function isContract(address addr) internal view returns (bool){
        if (addr == address(0)) {
            return false;
        }
        
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }

        return size > 0;
    }
}   

contract PaymentProcessor is AccessControl {
    using PaymentLib for address payable;
    error InvalidAddress();
    error InvalidFee();
    error NotSendEth();

    event PaymentProcessed(address indexed from, address indexed to, uint amountTransferred, uint feeCut);
    event TreasuryChanged(address indexed treasury);
    event FeeChanged(uint indexed fee);

    address payable private  treasury;
    uint private fee; 
    address private owner;
    bytes32 private constant TREASURY_ROLE = keccak256(abi.encodePacked("TREASURY_ROLE"));

    constructor(address payable _treasury, uint _fee) {
        treasury = _treasury;
        fee = _fee;
        owner = msg.sender;
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(TREASURY_ROLE, treasury);
    }

    function processPayment(address payable to) public payable {
        if (msg.value == 0) revert NotSendEth();
        if (to == address(0)) revert InvalidAddress();
        
        uint amountAfterFee = (msg.value * (100 - fee)) / 100;
        uint feeAmount = msg.value - amountAfterFee;
        
        bool feeTransferSuccess = treasury.transferETH(feeAmount);
        console.log("Fee transfer success:", feeTransferSuccess);
        bool paymentTransferSuccess = to.transferETH(amountAfterFee);
        console.log("Payment transfer success:", paymentTransferSuccess);
        
        emit PaymentProcessed(msg.sender, to, amountAfterFee, feeAmount);
    }

    function changeTreasury(address payable _newTreasury) public onlyRole(TREASURY_ROLE) {
        if (_newTreasury == address(0)) {
            revert InvalidAddress();
        }

        treasury = _newTreasury;
        emit TreasuryChanged(treasury);

    }

    function changeFee(uint _newFee) public onlyRole(TREASURY_ROLE) {
        if (_newFee == 0 || _newFee > 99) {
            revert InvalidFee();
        }

        fee = _newFee;
        emit FeeChanged(fee);
    }

    function getTreasury() public view returns (address _treasury) {
        _treasury = treasury;
    }   

    function getFee() public view returns (uint _fee) {
        _fee = fee;
    }
    function getOwner() public view returns (address _owner) {
        _owner = owner;
    }
}