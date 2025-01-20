// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract ArraySift {
    uint[] arr = [1,2,3,4];

    function remove(uint index) public {
        require(index < arr.length, "index out of bound");
        for (uint i = index; i < arr.length; i++) {
            arr[i] = arr[i + 1];
        }
        arr.pop();
    }
}

contract ArrayReplaceFromEnd {
    uint256[] public arr;

    function remove(uint256 index) public {
        arr[index] = arr[arr.length - 1];
        arr.pop();
    }
}