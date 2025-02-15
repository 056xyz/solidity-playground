// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

struct Card {
    uint id;
    string name;
    uint power;
    string spell;
}

library ArrayLib {
    function exists(Card[] memory cards, uint256 id) internal pure returns (bool) {
        uint length = cards.length;

        for (uint i = 0; i < length; i++) {
            if (cards[i].id == id) {
                return true;
            }
        }
        return false;
    }

    function removeAt(Card[] storage cards, uint index) internal {
        cards[index] = cards[cards.length - 1];
        cards.pop();
    }
}

contract CollectibleCardLibraryV2 {
    error CardIdExists();
    error UnauthorizedAccess();
    error IndexOutOfBound();
    using ArrayLib for Card[];

    address owner;
    mapping(address => Card[]) public collections;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) {
            revert UnauthorizedAccess();
        }
        _;
    }

    function addCard(uint id, string calldata name, uint power, string calldata spell) public onlyOwner returns (bool){
        if (collections[msg.sender].exists(id)) {
            revert CardIdExists();
        }

        collections[msg.sender].push(Card(id, name, power, spell));
    }

    function removeCardAt(uint index) public onlyOwner {
        if (index > collections[msg.sender].length) {
            revert IndexOutOfBound();
        }

        collections[msg.sender].removeAt(index);
    }
}