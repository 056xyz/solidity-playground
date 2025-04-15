// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @dev A contract that demonstrates inefficient function implementations
 */
contract FunctionGuzzler {
    uint256 public totalValue;
    uint256 public valueCount;
    uint256[] public values;
    mapping(uint256 => bool) public valueExists;
    mapping(address => uint256) public balances;
    mapping(address => bool) public isRegistered;
    address[] public users;

    event ValueAdded(address user, uint256 value);
    event Transfer(address from, address to, uint256 amount);


       // Custom errors
    error AlreadyRegistered();
    error NotRegistered();
    error ValueAlreadyExists();
    error SenderNotRegistered();
    error RecipientNotRegistered();
    error InsufficientBalance();


    function registerUser() external {
        if (isRegistered[msg.sender]) {
            revert AlreadyRegistered();
        } 
        isRegistered[msg.sender] = true;
        users.push(msg.sender);
    }

    function addValue(uint256 newValue) external {
        if (!isRegistered[msg.sender]) {
            revert NotRegistered();
        }
        if (valueExists[newValue]) {
            revert ValueAlreadyExists();
        }

        valueExists[newValue] = true;
        unchecked {
            totalValue += newValue;
            valueCount++;
        }

        emit ValueAdded(msg.sender, newValue);
    }

    function deposit(uint256 amount) external {
        if (!isRegistered[msg.sender]) {
            revert NotRegistered();
        }

        unchecked{
            balances[msg.sender] += amount;
            totalValue += amount;
        }
    }
    
    function transfer(address to, uint256 amount) external {
        if (!isRegistered[msg.sender]) {
            revert SenderNotRegistered();
        }
        if (!isRegistered[to]) {
            revert RecipientNotRegistered();
        }
        if (balances[msg.sender] < amount) {
            revert InsufficientBalance();
        }

        unchecked {
            balances[msg.sender] -= amount;
            balances[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);
    }

    function getAverageValue() external view returns (uint256) {
        return valueCount == 0 ? 0 : totalValue / valueCount;
    }
    function isUser(address user) external view returns (bool) {
        return isRegistered[user];
    }
}