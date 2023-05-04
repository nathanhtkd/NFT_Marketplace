const { ethers } = require("hardhat");

const TOKEN_ID = 1;
const NEW_PRICE = ethers.utils.parseEther(".5");

async function updateListing() {
    const accounts = await ethers.getSigners();
    const [deployer, owner, buyer1] = accounts;

    const IDENTITIES = {
        [deployer.address]: "DEPLOYER",
        [owner.address]: "OWNER",
        [buyer1.address]: "BUYER_1",
    };

    const nftMarketplaceContract = await ethers.getContract("Marketplace");
    const basicNftContract = await ethers.getContract("BasicNft");

    console.log(`Updating listing for token ID ${TOKEN_ID} with a new price`);
    const updateTx = await nftMarketplaceContract
        .connect(owner)
        .updateListing(basicNftContract.address, TOKEN_ID, NEW_PRICE);


    const updateTxReceipt = await updateTx.wait(1);
    const updatedPrice = updateTxReceipt.events[0].args.price;
    const formatEtherString = ethers.utils.formatEther(updatedPrice);
    console.log("updated price:  ", formatEtherString);
};

async function main() {
    console.log("\x1b[31m", "\nTESTING MARKETPLACE UPDATEPRICE");
    console.log("\x1b[37m");

    const wait1 = await updateListing();
}

main();
