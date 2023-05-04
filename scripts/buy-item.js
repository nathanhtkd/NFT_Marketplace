const { ethers } = require("hardhat");

const TOKEN_ID = 1;

async function buyItem() {
    const accounts = await ethers.getSigners();
    const [deployer, owner, buyer1] = accounts;

    const IDENTITIES = {
        [deployer.address]: "DEPLOYER",
        [owner.address]: "OWNER",
        [buyer1.address]: "BUYER_1",
    };

    const nftMarketplaceContract = await ethers.getContract("Marketplace");
    const basicNftContract = await ethers.getContract("BasicNft");

    const origOwner = await basicNftContract.ownerOf(TOKEN_ID);
    console.log(`The original owner of the NFT is ${origOwner}`);

    const listing = await nftMarketplaceContract.getListing(TOKEN_ID);

    const price = listing.price.toString();
    // const price = ethers.utils.parseEther(".25");
    const tx = await nftMarketplaceContract
        .connect(buyer1)
        .buyNft(basicNftContract.address, TOKEN_ID, {
            value: price,
        });
    await tx.wait(1);
    console.log("NFT Bought!");

    const newOwner = await basicNftContract.ownerOf(TOKEN_ID);
    console.log(
        `New owner of Token ID ${TOKEN_ID} is ${newOwner} with identity of ${IDENTITIES[newOwner]}`
    );
}

async function main() {
    console.log("\x1b[31m", "\nTESTING MARKETPLACE BUYITEM");
    console.log("\x1b[37m");
    const buyTest = await buyItem()
        .catch((error)=> {
            // console.error('\x1b[31mERROR', error.errorSignature, 'within the function', error.method);
            console.log(error["reason"]);
            process.exit(1);
        }
    );
}

main();
