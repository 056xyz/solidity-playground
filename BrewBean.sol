// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


interface ILoyaltyPoints{
    function rewardPoints(address customer, uint256 partner, uint256 amount) external;
    function redeemPoints( uint256 partner,  uint256 amount) external;
}

abstract contract BaseLoyaltyProgram is ILoyaltyPoints {
    error NotEnoughSpent();
    error NotPartner();
    error NotOwner();

    event Rewarded(address indexed customer, uint256 partner, uint256 amount);
    event Redeemed(address indexed customer, uint256 partner, uint256 amount);
    event RegisteredPartner(address indexed partner);

    struct Partner {
        string name;
        bool isRegistered;
        uint rewardPercent;
    }

    address owner;
    uint256 private constant SPENDING_TARGET = 100e18;
    uint256 idCounter;

    mapping(address user => mapping(uint256 partner => uint256 spent)) internal userSpendingPerPartner;
    mapping(address user => mapping(uint256 partner => uint256 points)) internal userPointsPerPartner;
    mapping(uint256 => Partner) internal partners;

    constructor()  {
        owner = msg.sender;
    }

    modifier _authorizeReward(address customer, uint256 partner) {
        if (userSpendingPerPartner[customer][partner] < SPENDING_TARGET) {
            revert NotEnoughSpent();
        }
        _;
    }

    modifier onlyPartner(uint256 partner) {
        if (!partners[partner].isRegistered) {
            revert NotPartner();
        }
        _;
    } 

    modifier onlyOwner {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    function _registerPartner(address partner, string memory _name, uint256 _rate) internal onlyOwner {
        partners[idCounter] = Partner({
            name: _name,
            isRegistered: true,
            rewardPercent: _rate
        });

        idCounter++;

        emit RegisteredPartner(partner);
    }

    function _rewardPoints(address customer, uint256 partner,  uint256 amount) internal _authorizeReward(customer, partner) onlyPartner(partner) {
        userPointsPerPartner[customer][partner] += (amount * 1e18);

        emit Rewarded(customer, partner, amount);
    }

    function _redeemPoints( uint256 partner,  uint256 amount) internal {
        userPointsPerPartner[msg.sender][partner] -= (amount * 1e18);
        
        emit Redeemed(msg.sender, partner, amount);
    }

    function _calculateReward(uint256 partnerId, uint256 amountSpent) internal view returns (uint256 _amount){
        Partner memory partner = partners[partnerId];
        uint256 rewardPercent = partner.rewardPercent;
        _amount = amountSpent / rewardPercent;
    }
}


contract BrewBeanPoints is BaseLoyaltyProgram, ERC20 {

    constructor() ERC20("BrewBeanToken", "BBT") {}

    function registerPartner(address _partner, string calldata _name, uint256 _rate) public  {
        _registerPartner(_partner, _name, _rate);
    }

    // amount is expected to be in bgn so i add additional precission
    function recordUserSpending(address customer, uint256 partner, uint256 amount) public onlyPartner(partner) {
        userSpendingPerPartner[customer][partner] += (amount * 1e18);
    }

    function rewardPoints(address customer, uint256 partner, uint256 amount) public {
        _rewardPoints(customer, partner, amount);
        uint amountToMint = _calculateReward(partner, amount);
        _mint(customer, amountToMint);
    }

    function redeemPoints(uint256 partner, uint256 amount) public {
        _burn(msg.sender, amount);
        _redeemPoints(partner, amount);
    }

    function getPartners(uint256 partnerId) public view returns (Partner memory partner){
        partner = partners[partnerId];
    }

    function getUserSpending(address _user, uint partnerId) public view returns (uint256 user){
        user = userSpendingPerPartner[_user][partnerId];
    }

    function getUserPoints(address _user, uint partnerId) public view returns (uint256 user){
        user = userPointsPerPartner[_user][partnerId];
    }
}


