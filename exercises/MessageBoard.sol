// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract MessageBoard {

    mapping(address => string) public messages;

    function storeMessage(string memory _message) public {
        messages[msg.sender] = _message;
    }
    
    function previewMessage(string memory _message) public view returns(string memory message){
        message = string(abi.encodePacked("Draft:", _message));
    }
}