// Import Hardhat runtime environment
const { ethers } = require("hardhat");

async function main() {
    // Get the contract factory
    const Greeter = await ethers.getContractFactory("Greeter");

    // Deploy the contract with an initial greeting message
    const greeter = await Greeter.deploy("Hello, Hardhat!");

    // Wait for deployment confirmation
    await greeter.waitForDeployment();

    const address = await greeter.getAddress();
    console.log(`Contract deployed to: ${address}`);
}

// Run the script and handle errors
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
