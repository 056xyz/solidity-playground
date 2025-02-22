const { task } = require("hardhat/config");

task("deploy", "Deploys StakingPool and Staking Token")
//   .addParam("owner", "Initial owner of NFT contract")
  .setAction(async (taskArgs: any, hre: any) => {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying contracts with account:", deployer.address);

    // StakingToken
    const StakingToken = await hre.ethers.getContractFactory("StakingToken");
    const stakingToken = await StakingToken.deploy();

    await stakingToken.waitForDeployment();

    console.log("StakingToken deployed to:", await stakingToken.getAddress());

    // StakingPool
    const StakingPool = await hre.ethers.getContractFactory("StakingPool");
    const stakingPool = await StakingPool.deploy(await stakingToken.getAddress());
    await stakingPool.waitForDeployment();
    console.log("StakingPool deployed to:", await stakingPool.getAddress());

    // Verify contracts if on Sepolia
    if (hre.network.name === "sepolia") {
      console.log("\nVerifying contracts on Sepolia...");

      // Wait for a few block confirmations
      console.log("Waiting for block confirmations...");
      await stakingToken.deploymentTransaction().wait(5);
      await stakingPool.deploymentTransaction().wait(5);

      // Verify stakingToken
      try {
        await hre.run("verify:verify", {
          address: await stakingToken.getAddress(),
          constructorArguments: [],
        });
        console.log("StakingToken verified successfully");
      } catch (error) {
        console.log("StakingToken verification failed:", error.message);
      }

      // Verify StakingPool
      try {
        await hre.run("verify:verify", {
          address: await stakingPool.getAddress(),
          constructorArguments: [await stakingPool.getAddress()],
        });
        console.log("StakingPool verified successfully");
      } catch (error) {
        console.log("StakingPool verification failed:", error.message);
      }
    }

    console.log("\nDeployment Summary:");
    console.log("-------------------");
    console.log("StakingToken:", await stakingToken.getAddress());
    console.log("StakingPool:", await stakingPool.getAddress());
  });
