const { ethers } = require("hardhat");

async function main() {
    console.log("\nGetting approved accounts");
    const nftMarketplaceContract = await ethers.getContract("Marketplace");
    const basicNftContract = await ethers.getContract("BasicNft");
    
    const approved = await basicNftContract.getApproved(0);

    console.log(approved);
}

main();
