const { ethers } = require("hardhat");

const TOKEN_ID = 2;

async function cancelListing() {
    const accounts = await ethers.getSigners();
    const [deployer, owner] = accounts;

    const nftMarketplaceContract = await ethers.getContract("Marketplace");
    const basicNftContract = await ethers.getContract("BasicNft");

    const tx = await nftMarketplaceContract
        .connect(owner)
        .unlistItem(basicNftContract.address, TOKEN_ID);
    const cancelTxReceipt = await tx.wait(1);
    const args = cancelTxReceipt.events[0].args;
    console.log(`NFT with ID ${TOKEN_ID} Canceled...`);

    // Check cancellation.
    // const canceledListing = await nftMarketplaceContract.getListing(TOKEN_ID);
    // console.log("Seller is Zero Address (i.e no one!)", canceledListing.seller);
}

async function main() {
    console.log("\x1b[31m", "\nTESTING MARKETPLACE UNLISTNFT");
    console.log("\x1b[37m");

    const wait1 = await cancelListing();
}

main();
