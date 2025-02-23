task('mint', 'Mint tokens')
.addParam('to', 'Address to mint tokens to')
.addParam('amount', 'Amount of tokens to mint')
.setAction(async (params, hre) => {
    const { to, amount } = params;
    const contractFactory = await ethers.getContractFactory('SimpleToken')
    const contract = await contractFactory.deploy()
    await contract.waitForDeployment();
    console.log('Contract deployed to:', await contract.getAddress());

    contract.mint(to, amount);
    console.log(`Minted ${amount} tokens to ${to}`);

    const balance = await contract.balanceOf(to);
    console.log(`Balance of ${to}: ${balance.toString()}`);

});

task('transfer', 'transfer tokens between addresses')
// .addParam('to', 'Address to transfer tokens to')
.addParam('amount', 'Amount of tokens to mint')
.setAction(async (params, hre) => {
    const { amount } = params;
    const [deployer, address1, address2] = await ethers.getSigners();
    const contractFactory = await ethers.getContractFactory('SimpleToken')
    const contract = await contractFactory.deploy()
    await contract.waitForDeployment();
    console.log('Contract deployed to:', await contract.getAddress());

    //mint tokens to someone so he can transfer them
    await contract.mint(address1.address, amount);
    console.log(`Minted ${amount} tokens to ${address1.address}`);

    const balance1 = await contract.balanceOf(address1.address);
    const balance2 = await contract.balanceOf(address2.address);
    console.log(`Balance of ${address1.address}: ${balance1.toString()}`);

    await contract.connect(deployer).approve(address1.address, amount);    
    await contract.connect(address1).transfer(address2.address, amount - 1);

    const newBalance1 = await contract.balanceOf(address1.address);
    const newBalance2 = await contract.balanceOf(address2.address);
    console.log(`Transferred ${amount} tokens from ${address1.address} to ${address2.address}`);
    console.log(`Balance of ${address1.address}: ${newBalance1.toString()}`);
    console.log(`Balance of ${address2.address}: ${newBalance2.toString()}`);

});



SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0; 
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; 
contract Staking is ReentrancyGuard { 
    mapping(address => uint256) public stakes; 
    mapping(address => uint256) public lastStakeTimestamp; 
    mapping(address => uint256) public rewards; 
    uint256 public constant MINIMUM_STAKE = 100; 
    uint256 public constant LOCK_PERIOD = 1 days; 
    uint256 public constant REWARD_RATE = 10; // 10% APR event Staked(address indexed user, uint256 amount); 
    event Withdrawn(address indexed user, uint256 amount); 
    event RewardClaimed(address indexed user, uint256 amount); 
    function stake() public payable nonReentrant { 
        require(msg.value >= MINIMUM_STAKE, "Stake too small"); // Calculate pending rewards before updating stake uint256 pendingReward = calculateReward(msg.sender); 
        rewards[msg.sender] += pendingReward; stakes[msg.sender] += msg.value; 
        lastStakeTimestamp[msg.sender] = block.timestamp; 
        emit Staked(msg.sender, msg.value); 
    } 
        function withdraw() public nonReentrant { require(stakes[msg.sender] > 0, "No stake found"); require(block.timestamp >= lastStakeTimestamp[msg.sender] + LOCK_PERIOD, "Lock period not over"); uint256 amount = stakes[msg.sender]; uint256 reward = calculateReward(msg.sender); stakes[msg.sender] = 0; rewards[msg.sender] = 0; // Transfers should be last payable(msg.sender).transfer(amount); payable(msg.sender).transfer(reward); emit Withdrawn(msg.sender, amount); emit RewardClaimed(msg.sender, reward); } function calculateReward(address user) public view returns (uint256) { if (stakes[user] == 0) return 0; uint256 duration = block.timestamp - lastStakeTimestamp[user];

return (stakes[user] * REWARD_RATE * duration) / (365 days * 100); } }
