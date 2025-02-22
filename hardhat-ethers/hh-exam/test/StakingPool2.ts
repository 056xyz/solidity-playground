const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("StakingPool", function () {
  async function deployStakingFixture() {
    // Get signers
    const [owner, staker, otherAccount] = await ethers.getSigners();

    // Deploy mock token first
    const StakingToken = await ethers.getContractFactory("StakingToken"); // You'll need to create this
    const stakingToken = await StakingToken.deploy();
    await stakingToken.waitForDeployment();

    // Deploy staking pool
    const StakingPool = await ethers.getContractFactory("StakingPool");
    const stakingPool = await StakingPool.deploy(await stakingToken.getAddress());
    await stakingPool.waitForDeployment();

    // Mint some tokens to staker and approve staking pool
    const mintAmount = ethers.parseEther("1000");
    await stakingToken.mint(staker.address, mintAmount);
    await stakingToken.connect(staker).approve(await stakingPool.getAddress(), mintAmount);

    // Initial stake for unstake tests
    const initialStakeAmount = ethers.parseEther("500");
    await stakingPool.connect(staker).stake(initialStakeAmount);

    return { stakingPool, stakingToken, owner, staker, otherAccount, mintAmount, initialStakeAmount };
  }

  describe("stake", function () {
    it("should revert when staking amount is zero", async function () {
      const { stakingPool, staker } = await loadFixture(deployStakingFixture);
      
      await expect(stakingPool.connect(staker).stake(0))
        .to.be.revertedWithCustomError(stakingPool, "CannotBeZero");
    });

    it("should transfer tokens from staker to contract", async function () {
      const { stakingPool, stakingToken, staker } = await loadFixture(deployStakingFixture);
      const stakeAmount = ethers.parseEther("100");

      await expect(stakingPool.connect(staker).stake(stakeAmount))
        .to.changeTokenBalances(
          stakingToken,
          [staker.address, await stakingPool.getAddress()],
          [-stakeAmount, stakeAmount]
        );
    });

    it("should update staker's data correctly", async function () {
      const { stakingPool, staker } = await loadFixture(deployStakingFixture);
      const stakeAmount = ethers.parseEther("100");

      await stakingPool.connect(staker).stake(stakeAmount);
      
      const stakerData = await stakingPool.stakers(staker.address);
      expect(stakerData.stakedAmount).to.equal(stakeAmount + ethers.parseEther("500")); // Adding initial stake
      expect(stakerData.stakingStartTime).to.be.greaterThan(0);
    });

    it("should emit Staked event", async function () {
      const { stakingPool, staker } = await loadFixture(deployStakingFixture);
      const stakeAmount = ethers.parseEther("100");

      await expect(stakingPool.connect(staker).stake(stakeAmount))
        .to.emit(stakingPool, "Staked")
        .withArgs(staker.address, stakeAmount);
    });

    it("should revert if allowance is insufficient", async function () {
      const { stakingPool, stakingToken, staker } = await loadFixture(deployStakingFixture);
      
      // Reset allowance to 0
      await stakingToken.connect(staker).approve(await stakingPool.getAddress(), 0);
      
      const stakeAmount = ethers.parseEther("100");
      await expect(stakingPool.connect(staker).stake(stakeAmount))
         .to.be.revertedWithCustomError(stakingToken, "ERC20InsufficientAllowance");
    });

    it("should allow multiple stakes from the same user", async function () {
      const { stakingPool, staker, initialStakeAmount } = await loadFixture(deployStakingFixture);
      const stakeAmount = ethers.parseEther("100");

      // Additional stake (initial stake already done in fixture)
      await stakingPool.connect(staker).stake(stakeAmount);
      
      const stakerData = await stakingPool.stakers(staker.address);
      expect(stakerData.stakedAmount).to.equal(initialStakeAmount + stakeAmount);
    });

    it("should update rewards when staking additional amounts", async function () {
      const { stakingPool, staker } = await loadFixture(deployStakingFixture);
      const stakeAmount = ethers.parseEther("100");
      
      // Wait some time
      await ethers.provider.send("evm_increaseTime", [3600]); // 1 hour
      await ethers.provider.send("evm_mine");
      
      // Additional stake should trigger reward update
      await expect(stakingPool.connect(staker).stake(stakeAmount))
        .to.emit(stakingPool, "RewardUpdated");
    });
  });

  describe("unstake", function () {
    it("should revert when unstaking amount is zero", async function () {
      const { stakingPool, staker } = await loadFixture(deployStakingFixture);
      
      await expect(stakingPool.connect(staker).unStake(0))
        .to.be.revertedWithCustomError(stakingPool, "CannotBeZero");
    });

    it("should revert when unstaking more than staked amount", async function () {
      const { stakingPool, staker, initialStakeAmount } = await loadFixture(deployStakingFixture);
      const tooMuch = initialStakeAmount + 1n;
      
      await expect(stakingPool.connect(staker).unStake(tooMuch))
        .to.be.revertedWithCustomError(stakingPool, "InsufficientBalance");
    });

    it("should revert when trying to unstake before minimum duration", async function () {
      const { stakingPool, staker } = await loadFixture(deployStakingFixture);
      const unstakeAmount = ethers.parseEther("100");
      
      await expect(stakingPool.connect(staker).unStake(unstakeAmount))
        .to.be.revertedWithCustomError(stakingPool, "CannotUnStakeYet");
    });

    it("should allow unstaking after minimum duration", async function () {
      const { stakingPool, staker } = await loadFixture(deployStakingFixture);
      const unstakeAmount = ethers.parseEther("100");
      
      // Wait for minimum staking duration (60 seconds)
      await ethers.provider.send("evm_increaseTime", [61]);
      await ethers.provider.send("evm_mine");

      await expect(stakingPool.connect(staker).unStake(unstakeAmount))
        .to.not.be.reverted;
    });

    it("should transfer tokens back to staker", async function () {
      const { stakingPool, stakingToken, staker } = await loadFixture(deployStakingFixture);
      const unstakeAmount = ethers.parseEther("100");
      
      await ethers.provider.send("evm_increaseTime", [61]);
      await ethers.provider.send("evm_mine");

      await expect(stakingPool.connect(staker).unStake(unstakeAmount))
        .to.changeTokenBalances(
          stakingToken,
          [staker.address, await stakingPool.getAddress()],
          [unstakeAmount, -unstakeAmount]
        );
    });

    it("should update staker's data correctly", async function () {
      const { stakingPool, staker, initialStakeAmount } = await loadFixture(deployStakingFixture);
      const unstakeAmount = ethers.parseEther("100");
      
      await ethers.provider.send("evm_increaseTime", [61]);
      await ethers.provider.send("evm_mine");

      await stakingPool.connect(staker).unStake(unstakeAmount);
      
      const stakerData = await stakingPool.stakers(staker.address);
      expect(stakerData.stakedAmount).to.equal(initialStakeAmount - unstakeAmount);
      expect(stakerData.stakingStartTime).to.be.greaterThan(0);
    });

    it("should emit UnStaked event", async function () {
      const { stakingPool, staker } = await loadFixture(deployStakingFixture);
      const unstakeAmount = ethers.parseEther("100");
      
      await ethers.provider.send("evm_increaseTime", [61]);
      await ethers.provider.send("evm_mine");

      await expect(stakingPool.connect(staker).unStake(unstakeAmount))
        .to.emit(stakingPool, "UnStaked")
        .withArgs(staker.address, unstakeAmount);
    });

    it("should update rewards when unstaking", async function () {
      const { stakingPool, staker } = await loadFixture(deployStakingFixture);
      const unstakeAmount = ethers.parseEther("100");
      
      await ethers.provider.send("evm_increaseTime", [61]);
      await ethers.provider.send("evm_mine");

      await expect(stakingPool.connect(staker).unStake(unstakeAmount))
        .to.emit(stakingPool, "RewardUpdated");
    });
    
    it("should reset staking start time after unstaking", async function () {
      const { stakingPool, staker } = await loadFixture(deployStakingFixture);
      const unstakeAmount = ethers.parseEther("100");
      
      await ethers.provider.send("evm_increaseTime", [61]);
      const blockBefore = await ethers.provider.getBlock("latest");
      
      await stakingPool.connect(staker).unStake(unstakeAmount);
      
      const stakerData = await stakingPool.stakers(staker.address);
      expect(stakerData.stakingStartTime).to.be.greaterThan(blockBefore.timestamp);
    });
  });
});