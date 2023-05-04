const { ethers } = require("hardhat");


async function main () {
    console.log("\nGetting listed NFTs\n");
    const nftMarketplaceContract = await ethers.getContract("Marketplace");
    const nftArray = await nftMarketplaceContract.getListedNfts();
    for (let i = 0; i < nftArray.length; ++i) {
        const [nftAddress, tokenID, owner, price] = nftArray[i];
        
        console.log(`NFT Address: ${nftAddress}`);
        console.log(`Token ID: ${tokenID}`);
        console.log(`Owner: ${owner}`);
        console.log(`Price: ${ethers.utils.formatEther(price)}`);
        console.log("----------------------");
    }
}

main();
