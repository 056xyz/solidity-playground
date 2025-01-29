// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
import "hardhat/console.sol";

contract AssetFactory {
    event AssetTransferred(Asset asset, address sender, address to, string symbol);

    mapping(string => Asset) assets;

    function createAsset(string memory symbol, string memory name, uint initialSupply) public returns(Asset){
        Asset createdAsset = new Asset(symbol, name, initialSupply);
        assets[symbol] = createdAsset;
        
        return createdAsset;
    }

    function getAsset(string memory _symbol) public view returns(Asset) {
        return assets[_symbol];
    }   

    function transferAsset( address _to, string memory _symbol, uint _amount) public {
        Asset assetAddress = assets[_symbol];
        require(address(assetAddress) != address(0), "Asset does not exist");

        Asset(assetAddress).transfer(_to, _amount);

        emit AssetTransferred(assetAddress, msg.sender, _to, _symbol);
    }
}

// interface IAsset{
//     function transfer(address to, uint amount) external;
// }

contract Asset {

    event Transfer(address indexed from, address indexed to, uint256 value);

    string symbol;
    string name;
    uint initialSupply;

    mapping(address => uint256) public balances;

    constructor(string memory _symbol, string memory _name, uint _initialSupply){
        symbol = _symbol;
        name = _name;
        initialSupply = _initialSupply;
        balances[msg.sender] = initialSupply;
    }   

    function transfer(address to, uint amount) external moreThanZero(amount) balanceCheck(amount) {
        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }   

    modifier moreThanZero(uint256 amount) {
        require(amount != 0, "Cannot be zero amount");
        _;
    }

    modifier balanceCheck(uint256 amount) {
        require(balances[msg.sender] >= amount, "Not enough balance");
        _;
    }
}