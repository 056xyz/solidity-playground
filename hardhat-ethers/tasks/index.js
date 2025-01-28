task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();
    
    for(const account of accounts) {
        console.log(account.address);
    }
})

task("balance", "Prints the balance of the first account", async (_, hre) => {
    const provider = await hre.ethers.provider

    const balance = await provider.getBalance("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
    
    console.log(ethers.formatEther(balance))
})

//always 0? 
task("blockNumber", "Current block number", async (_, hre) => {
    const provider = await hre.ethers.provider

    const blockNumber = await provider.getBlockNumber()

    console.log(blockNumber)
})

task("send", "Send ETH to an address")
    .addParam("address", "the address to send to")
    .addParam("amount", "the amount to send")
    .setAction(async (params, hre) => {
    const [signer] = await hre.ethers.getSigners();
    const tx = await signer.sendTransaction({
        to: params.address,
        value: ethers.parseEther(params.amount)
    })

    console.log("Tx send")
    console.log(tx)
    const receipt = await tx.wait()
    console.log("Tx mined")
    console.log(receipt)

})

task("contract", "Current block number", async (params, hre) => {
    const contractFactory = await hre.ethers.getContractFactory("Lock")
    const contract = await contractFactory.deploy(1738989710)

    console.log("Contract dedployed to:", await contract.getAddress())

    const tx = await contract.withdraw().catch(err => console.log(err.message))
    console.log("Tx send!")
})