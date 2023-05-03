// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error PriceMustBeGreaterThanZero();
error TransactionFeeNotIncluded();
error ItemIsNotListed();
error NoProceeds();
error NotTheOwnerOfThisNFT();
error ValueNotThePrice(uint256 price);

/*
    CURRENT FUNCTIONS:
    1. listItem
    2. unlistItem
    3. buyNFT
    4. withdrawProceeds
    5. updateListing

    NEED TO IMPLEMENT?
    1. getListedNFT
    2. getListing
    3. auction??

*/
contract Marketplace is ReentrancyGuard {

    address payable public owner;  
    mapping(uint256 => NFT) public nftListings;
    mapping(uint256 => bool) public isListed;
    mapping(address => uint256) private sellerProceeds;
    uint256 public constant TRANSACTION_FEE = 100 wei;
    uint256 public constant LISTING_FEE = 1 wei;

    event ItemListed(address indexed seller, address indexed nftAddress, uint256 tokenID, uint256 price);
    event ItemCanceled(address indexed seller, address indexed nftAddress, uint256 indexed tokenID);
    event ItemBought(address indexed buyer, address indexed nftAddress, uint256 price);

    struct NFT {
        address nftAddress;
        uint256 tokenID;
        address owner;
        uint256 price;
    }
    
    constructor() {
        owner = payable(msg.sender);
    }

    function listItem(address nftAddress, uint256 tokenID, uint256 price) public payable nonReentrant {
        if(price < 0) {
            revert PriceMustBeGreaterThanZero();
        }
        if(msg.value != TRANSACTION_FEE) {
            revert TransactionFeeNotIncluded();
        }

        // transfers ownership from original owner of NFT to marketplace address
        IERC721(nftAddress).transferFrom(msg.sender, address(this), tokenID);
        owner.transfer(LISTING_FEE);

        nftListings[tokenID] = NFT(nftAddress, tokenID, msg.sender, price); 
        isListed[tokenID] = true;

        emit ItemListed(msg.sender, nftAddress, tokenID, price);
    }

    function unlistItem(address nftAddress, uint256 tokenID) public {
        if(isListed[tokenID] != true) {
            revert ItemIsNotListed();
        }
        if(nftListings[tokenID].owner != msg.sender) {
            revert NotTheOwnerOfThisNFT();
        }
        IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenID);
        delete(nftListings[tokenID]);
        isListed[tokenID] = false;
        emit ItemCanceled(msg.sender, nftAddress, tokenID);
    }

    function updateListing(address nftAddress, uint256 tokenID, uint256 newPrice) public {
        if(isListed[tokenID] != true) {
            revert ItemIsNotListed();
        }
        if(nftListings[tokenID].owner != msg.sender) {
            revert NotTheOwnerOfThisNFT();
        }
        if(newPrice <= 0) {
            revert PriceMustBeGreaterThanZero();
        }
        nftListings[tokenID].price = newPrice;

        emit ItemListed(msg.sender, nftAddress, tokenID, newPrice);

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

        emit ItemBought(msg.sender, nftAddress, nft.price);
    }

    function withdrawProceeds() public {
        uint256 proceeds = sellerProceeds[msg.sender];
        if(proceeds <= 0) {
            revert NoProceeds();
        }
        sellerProceeds[msg.sender] = 0;
        payable(msg.sender).transfer(proceeds);
    }

    function viewProceeds(address seller) public view returns(uint256) {
        return sellerProceeds[seller];
    }
}
    