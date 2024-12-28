 // SPDX-License-Identifier: MIT
    pragma solidity 0.8.26;
    
    // This task involves creating a decentralized savings account system where users can create savings plans with predefined lock periods. 
    // Each user can contribute funds to their savings plan, view their plan data temporarily, and withdraw funds only after the lock period has expired.
    contract SavingsAccount {
    error LockPeriod();
    error IndexOutOfBounds();

    struct SavingsAccountData {
        uint balance;
        address owner;
        uint creationTime;
        uint lockPeriod;
    }

    mapping(address => SavingsAccountData[]) private userToSavingAccounts;
    
    function createSavingsPlan(uint lockPeriod, uint amount) public {
       SavingsAccountData memory _newSavingAccount;
       _newSavingAccount.balance = amount;
       _newSavingAccount.creationTime = block.timestamp;
       _newSavingAccount.owner = msg.sender;
       _newSavingAccount.lockPeriod =  lockPeriod;

       userToSavingAccounts[msg.sender].push(_newSavingAccount);
    }
    function viewSavingsPlan(uint index) public view returns (SavingsAccountData memory _savingAccount){
         SavingsAccountData[] memory _savingAccounts = userToSavingAccounts[msg.sender];
         if (_savingAccounts.length < index || _savingAccounts.length == 0) {
            revert IndexOutOfBounds();
        }
        _savingAccount = userToSavingAccounts[msg.sender][index];
    }

    function withdrawFunds(uint index) public {
        SavingsAccountData[] memory _savingAccounts = userToSavingAccounts[msg.sender];
        if (_savingAccounts.length < index || _savingAccounts.length == 0) {
            revert IndexOutOfBounds();
        }
        SavingsAccountData storage _savingAccount = userToSavingAccounts[msg.sender][index];

        if (block.timestamp < _savingAccount.creationTime + _savingAccount.lockPeriod) {
            revert LockPeriod();
        }

         delete _savingAccount.balance;
         delete _savingAccount.owner;
         delete _savingAccount.lockPeriod;
    }
}