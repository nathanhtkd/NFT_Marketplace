const { ethers } = require("hardhat");


async function main () {
    console.log("\nGetting listed NFTs");
    const nftMarketplaceContract = await ethers.getContract("Marketplace");
    const nftArray = await nftMarketplaceContract.getListedNfts();
    for (let i = 0; i < nftArray.length; ++i) {
        console.log(nftArray[i]);
        // console.log(
        //     `${i}. ${nftArray[i][4]} with token ID: ${nftArray[
        //         i
        //     ].tokenID.toNumber()}`
        // );
    }
}

main();
