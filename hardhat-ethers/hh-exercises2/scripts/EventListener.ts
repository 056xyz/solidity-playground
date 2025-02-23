// scripts/event-listener.js
import { ethers } from "hardhat"

async function main() {
    try {
        // Deploy the contract first
        const [owner, player1, player2] = await ethers.getSigners();
        console.log("Deploying contract with account:", owner.address);

        const GameToken = await ethers.getContractFactory("SimpleToken");
        const gameToken = await GameToken.deploy();
        await gameToken.waitForDeployment();

        const contractAddress = await gameToken.getAddress();
        console.log("GameToken deployed to:", contractAddress);

        // Get contract instance using getContractAt
        const contract = await ethers.getContractAt("SimpleToken", contractAddress);

        console.log("\nStarting to listen for Transfer events...");
        console.log("--------------------------------------------");

        // Listen for all Transfer events
        contract.on(contract.filters.Transfer(), (from, to, value, event) => {
            console.log("\nNew Transfer Event Detected!");
            console.log("From:", from);
            console.log("To:", to);
            console.log("Value:", ethers.formatEther(value), "STK");
            
            // Additional event information
            console.log("\nEvent Details:");
            console.log("Block Number:", event.blockNumber);
            console.log("Transaction Hash:", event.transactionHash);
            console.log("--------------------------------------------");
        });

        // Optional: Filter for specific addresses
        // Example: Only listen for transfers to player1
        // const filterToPlayer1 = contract.filters.Transfer(undefined, player1.address);
        // contract.on(filterToPlayer1, (from, to, value, event) => {
        //     console.log("\nTransfer to Player 1 Detected!");
        //     console.log("From:", from);
        //     console.log("Value:", ethers.formatEther(value), "GTK");
        //     console.log("--------------------------------------------");
        // });

        // Mint some tokens to test the event listener
        console.log("\nMinting tokens to test events...");
        const mintAmount = ethers.parseEther("50");
        
        // Mint to player1 and player2 to trigger events
        await gameToken.mint(player1.address, mintAmount);
        await gameToken.mint(player2.address, mintAmount);

        // Transfer between players to trigger another event
        const gameTokenPlayer1 = gameToken.connect(player1);
        await gameTokenPlayer1.transfer(player2.address, ethers.parseEther("10"));

        // Keep the script running
        process.stdin.resume();

        // Handle script termination
        const cleanup = () => {
            console.log("\nCleaning up...");
            // Remove all listeners
            contract.removeAllListeners();
            process.exit(0);
        };

        // Handle termination signals
        process.on('SIGINT', cleanup);
        process.on('SIGTERM', cleanup);
        process.on('SIGQUIT', cleanup);

    } catch (error) {
        console.error("Error:", error);
        process.exit(1);
    }
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});