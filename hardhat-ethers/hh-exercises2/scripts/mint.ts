import { ethers } from "hardhat"

async function main() {
    const [owner, player1, player2] = await ethers.getSigners()
    const provider  = ethers.getDefaultProvider();

    console.log("Deploying contracts with the account:", owner.address);
    console.log("Player 1 address:", player1.address);
    console.log("Player 2 address:", player2.address);

     // Deploy the token contract
     const GameToken = await ethers.getContractFactory("SimpleToken");
     const gameToken = await GameToken.deploy();
     await gameToken.waitForDeployment();
     console.log("GameToken deployed to:", await gameToken.getAddress());

     const initialBalance1 = await provider.getBalance(player1.address);
     const initialBalance2 = await provider.getBalance(player2.address);

     console.log("\nInitial balances:");
     console.log("Player 1:", ethers.formatEther(initialBalance1), "STK");
     console.log("Player 2:", ethers.formatEther(initialBalance2), "STK");

    const mintAmount = ethers.parseEther("100");

    await gameToken.mint(player1.address, mintAmount);
    await gameToken.mint(player2.address, mintAmount);

    const updatedBalance1 = await gameToken.balanceOf(player1.address);
    const updatedBalance2 = await gameToken.balanceOf(player2.address);

    console.log("\nBalances after minting:");
    console.log("Player 1:", ethers.formatEther(updatedBalance1), "STK");
    console.log("Player 2:", ethers.formatEther(updatedBalance2), "STK");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });