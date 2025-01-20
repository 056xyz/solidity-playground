// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;


contract IterableMapping {
    mapping(address => uint) public balances;
    mapping(address => bool) public inserted;
    address[] public keys;

    function set(address key, uint value) public {
        balances[key] = value;

        if (!inserted[key]) {
            inserted[key] = true;
            keys.push(key);
        }
    }

    function getSize() public view returns(uint) {
        return keys.length;
    }

    function first() public view returns (uint) {
        return balances[keys[0]];
    }

    function last() public view returns (uint) {
        return balances[keys[keys.length - 1]];
    }
     function get(uint index) public view returns (uint) {
        return balances[keys[index]];
    }
}