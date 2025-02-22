// const { expect } = require("chai");
// const { ethers } = require("hardhat");
// const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

// describe("StakingPool", function () {
//   async function deployStakingFixture() {
//     // Get signers
//     const [owner, staker, otherAccount] = await ethers.getSigners();

//     // Deploy mock token first
//     const StakingToken = await ethers.getContractFactory("StakingToken"); // You'll need to create this
//     const stakingToken = await StakingToken.deploy();
//     await stakingToken.waitForDeployment();

//     // Deploy staking pool
//     const StakingPool = await ethers.getContractFactory("StakingPool");
//     const stakingPool = await StakingPool.deploy(await stakingToken.getAddress());
//     await stakingPool.waitForDeployment();

//     // Mint some tokens to staker and approve staking pool
//     const mintAmount = ethers.parseEther("1000");
//     await stakingToken.mint(staker.address, mintAmount);
//     await stakingToken.connect(staker).approve(await stakingPool.getAddress(), mintAmount);

//     return { stakingPool, stakingToken, owner, staker, otherAccount, mintAmount };
//   }

//   describe("stake", function () {
//     it("should revert when staking amount is zero", async function () {
//       const { stakingPool, staker } = await loadFixture(deployStakingFixture);
      
//       await expect(stakingPool.connect(staker).stake(0))
//         .to.be.revertedWithCustomError(stakingPool, "CannotBeZero");
//     });

//     it("should transfer tokens from staker to contract", async function () {
//       const { stakingPool, stakingToken, staker } = await loadFixture(deployStakingFixture);
//       const stakeAmount = ethers.parseEther("100");

//       await expect(stakingPool.connect(staker).stake(stakeAmount))
//         .to.changeTokenBalances(
//           stakingToken,
//           [staker.address, await stakingPool.getAddress()],
//           [-stakeAmount, stakeAmount]
//         );
//     });

//     it("should update staker's data correctly", async function () {
//       const { stakingPool, staker } = await loadFixture(deployStakingFixture);
//       const stakeAmount = ethers.parseEther("100");

//       await stakingPool.connect(staker).stake(stakeAmount);
      
//       const stakerData = await stakingPool.stakers(staker.address);
//       expect(stakerData.stakedAmount).to.equal(stakeAmount);
//       expect(stakerData.stakingStartTime).to.be.greaterThan(0);
//     });

//     it("should emit Staked event", async function () {
//       const { stakingPool, staker } = await loadFixture(deployStakingFixture);
//       const stakeAmount = ethers.parseEther("100");

//       await expect(stakingPool.connect(staker).stake(stakeAmount))
//         .to.emit(stakingPool, "Staked")
//         .withArgs(staker.address, stakeAmount);
//     });

//     it("should revert if allowance is insufficient", async function () {
//       const { stakingPool, stakingToken, staker } = await loadFixture(deployStakingFixture);
      
//       // Reset allowance to 0
//       await stakingToken.connect(staker).approve(await stakingPool.getAddress(), 0);
      
//       const stakeAmount = ethers.parseEther("100");
//       await expect(stakingPool.connect(staker).stake(stakeAmount))
//          .to.be.revertedWithCustomError(stakingToken, "ERC20InsufficientAllowance");
//     });

//     it("should allow multiple stakes from the same user", async function () {
//       const { stakingPool, staker } = await loadFixture(deployStakingFixture);
//       const stakeAmount = ethers.parseEther("100");

//       // First stake
//       await stakingPool.connect(staker).stake(stakeAmount);
      
//       // Second stake
//       await stakingPool.connect(staker).stake(stakeAmount);
      
//       const stakerData = await stakingPool.stakers(staker.address);
//       expect(stakerData.stakedAmount).to.equal(stakeAmount * 2n);
//     });

//     it("should update rewards when staking additional amounts", async function () {
//       const { stakingPool, staker } = await loadFixture(deployStakingFixture);
//       const stakeAmount = ethers.parseEther("100");

//       // First stake
//       await stakingPool.connect(staker).stake(stakeAmount);
      
//       // Wait some time
//       await ethers.provider.send("evm_increaseTime", [3600]); // 1 hour
//       await ethers.provider.send("evm_mine");
      
//       // Second stake should trigger reward update
//       await expect(stakingPool.connect(staker).stake(stakeAmount))
//         .to.emit(stakingPool, "RewardUpdated");
//     });
//   });
// });