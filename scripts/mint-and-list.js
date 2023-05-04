const { ethers } = require("hardhat");

// turns .1 ETH into wei
const PRICE = ethers.utils.parseEther("0.1");
const LISTING_FEE = ethers.utils.parseEther("1");

async function mintAndList() {
    const accounts = await ethers.getSigners();
    const [deployer, owner, buyer1] = accounts;

    const IDENTITIES = {
        [deployer.address]: "DEPLOYER",
        [owner.address]: "OWNER",
        [buyer1.address]: "BUYER_1",
    };

    const nftMarketplaceContract = await ethers.getContract("Marketplace");
    const basicNftContract = await ethers.getContract("BasicNft");

    console.log(`Minting NFT for ${owner.address}\n`);
    const mintTx = await basicNftContract.connect(owner).mintNft();
    // wait for the transaction to be confirmed by the network
    const mintTxReceipt = await mintTx.wait(1);

    const tokenId = mintTxReceipt.events[0].args.tokenId;

    // NFT owner muyst approve NFT marketplace so that NFT marketplace is allowed to transfer ownership
    console.log("Approving Marketplace as operator of NFT...\n");
    const approvalTx = await basicNftContract
        .connect(owner)
        .approve(nftMarketplaceContract.address, tokenId);
    const approvalTxReceipt = await approvalTx.wait(1);

    console.log("Listing NFT...");
    const tx = await nftMarketplaceContract
        .connect(owner)
        .listItem(basicNftContract.address, tokenId, PRICE, {
            value: LISTING_FEE,
        });
    await tx.wait(1);
    console.log(`NFT Listed with token ID: ${tokenId}\n`);

    const mintedBy = await basicNftContract.ownerOf(tokenId);
    if (owner.address != mintedBy) {
        console.log("WHAT THE FUCK");
        console.log(owner.address);
        console.log(mintedBy);
    }
    console.log(
        `NFT with ID ${tokenId} minted and listed by ${mintedBy} with identity ${IDENTITIES[mintedBy]}`
    );

    console.log("\nGetting listed NFTs");
    const nftArray = await nftMarketplaceContract.getListedNfts();
    for (let i = 0; i < nftArray.length; ++i) {
        console.log(
            `${i}. ${nftArray[i][0]} with token ID: ${nftArray[
                i
            ].tokenID.toNumber()}`
        );
    }
}

async function main() {
    const nftMarketplaceContract = await ethers.getContract("Marketplace");
    const cOwner = await nftMarketplaceContract.owner();

    console.log(`\x1b[33m\nOwner of Marketplace contract is ${cOwner}`);

    console.log("\x1b[31m", "\nTESTING MARKETPLACE LISTNFT");
    console.log("\x1b[37m");
    const mintAndListTest = await mintAndList();

    console.log("\x1b[31m", "\nMINTING ANOTHER NFT");
    console.log("\x1b[37m");
    const mintAndListTest1 = await mintAndList();

    console.log("\x1b[31m", "\nMINTING ANOTHER NFT");
    console.log("\x1b[37m");
    const mintAndListTest2 = await mintAndList();
}

main();
