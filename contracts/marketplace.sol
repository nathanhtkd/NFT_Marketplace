// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    How does an nft contract interact with the marketplace? TEST
*/

// NFT standard is ERC721
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// reentrant guard 
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error PriceMustBeGreaterThanZero();
error TransactionFeeNotIncluded();
error ItemIsNotListed();
error NotTheOwnerOfThisNFT();
error ValueNotThePrice(uint256 price);

contract Marketplace is ReentrancyGuard {

    address payable public owner;  
    
    struct NFT {
    address nftAddress;
    uint256 tokenID;
    address owner;
    uint256 price;
    }
    
    // Mapping of NFT token ID to its current owner
    mapping(uint256 => NFT) public nftListings;
    mapping(uint256 => bool) public isListed;
    mapping(address => uint256) private sellerProceeds;
    uint256 public transactionFee;

    constructor() {
        owner = payable(msg.sender);
        transactionFee = 100;
    }

    function listItem(address nftAddress, uint256 tokenID, uint256 price) public payable nonReentrant {
        if(price < 0) {
            revert PriceMustBeGreaterThanZero();
        }
        if(msg.value != transactionFee) {
            revert TransactionFeeNotIncluded();
        }

        // transfers ownership from original owner of NFT to marketplace address
        IERC721(nftAddress).transferFrom(msg.sender, address(this), tokenID);
        
        nftListings[tokenID] = NFT(nftAddress, tokenID, msg.sender, price); 
        isListed[tokenID] = true;
    }

    function unlistItem(address nftAddress, uint256 tokenID) public {
        if(isListed[tokenID] != true) {
            revert ItemIsNotListed();
        }
        if(nftListings[tokenID].owner != msg.sender) {
            revert NotTheOwnerOfThisNFT();
        }
        IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenID);
        isListed[tokenID] = false;
    }

    function buyNft(address nftAddress, uint256 tokenID) public payable nonReentrant {
        if(isListed[tokenID] != true) {
                revert ItemIsNotListed();
        }

        NFT storage nft = nftListings[tokenID];
        if(msg.value != nft.price) {
            revert ValueNotThePrice(nft.price);
        }

        sellerProceeds[nft.owner] += msg.value;
        IERC721(nftAddress).transferFrom(address(this), msg.sender, nft.tokenID);
        nft.owner = msg.sender;
        isListed[tokenID] = false;
    }

    function withdrawProceeds() public {
        uint256 b = sellerProceeds[msg.sender];
        sellerProceeds[msg.sender] = 0;
        payable(msg.sender).transfer(b);
    }
}
    