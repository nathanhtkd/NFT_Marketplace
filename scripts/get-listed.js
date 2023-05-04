const { ethers } = require("hardhat");


async function main () {
    console.log("\x1b[31m\nGetting listed NFTs\n");
    const nftMarketplaceContract = await ethers.getContract("Marketplace");
    const nftArray = await nftMarketplaceContract.getListedNfts();
    for (let i = 0; i < nftArray.length; ++i) {
        const [nftAddress, tokenID, owner, price] = nftArray[i];
        if(nftAddress === ethers.constants.AddressZero){
            continue;
        } else {
            console.log(`\x1b[36mNFT Address: ${nftAddress}`);
            console.log(`\x1b[32mToken ID: ${tokenID}`);
            console.log(`\x1b[35mOwner: ${owner}`);
            console.log(`\x1b[33mPrice: ${ethers.utils.formatEther(price)}`);
            console.log("----------------------");
        }
    }
}

main();
