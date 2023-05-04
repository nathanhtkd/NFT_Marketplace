const { ethers, network } = require("hardhat");

async function getProceeds() {
    const accounts = await ethers.getSigners();
    const [deployer, owner] = accounts;

    const nftMarketplaceContract = await ethers.getContract("Marketplace");
    const basicNftContract = await ethers.getContract("BasicNft");

    const proceeds = await nftMarketplaceContract.viewProceeds(owner.address);

    const proceedsWei = ethers.utils.formatEther(proceeds.toString());
    console.log(`Seller ${owner.address} has ${proceedsWei} eth to pull!`);
}

async function main() {
    console.log("\x1b[31m", "\nVIEW PROCEEDS TEST");
    console.log("\x1b[37m");

    const wait1 = await getProceeds();
}


main();