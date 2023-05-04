// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error PriceMustBeGreaterThanZero();
error TransactionFeeNotIncluded();
error ItemIsNotListed();
error NoProceeds();
error NotTheOwnerOfThisNFT();
error MarketplaceNotApproved(address nftAddress);
error ValueNotThePrice(uint256 price);

contract Marketplace is ReentrancyGuard {

    address payable public owner;  
    uint256 nftCount;
    mapping(uint256 => NFT) public nftListings;
    mapping(uint256 => bool) public isListed;
    mapping(address => uint256) private sellerProceeds;
    uint256 public constant TRANSACTION_FEE = 100 wei;
    uint256 public constant LISTING_FEE = 1 ether;

    event ItemListed(address indexed seller, address indexed nftAddress, uint256 tokenID, uint256 price);
    event ItemCanceled(address indexed seller, address indexed nftAddress, uint256 indexed tokenID);
    event ItemBought(address indexed buyer, address indexed nftAddress, uint256 price);
    event ProceedsWithdrawn(uint256 proceeds);


    struct NFT {
        address nftAddress;
        uint256 tokenID;
        address owner;
        uint256 price;
    }
    
    constructor() {
        owner = payable(msg.sender);
        nftCount = 0;
    }

    function listItem(address nftAddress, uint256 tokenID, uint256 price) public payable nonReentrant {
        if(price < 0) {
            revert PriceMustBeGreaterThanZero();
        }
        if(msg.value <= TRANSACTION_FEE) {
            revert TransactionFeeNotIncluded();
        }
        
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenID) != address(this)) {
            revert MarketplaceNotApproved(nftAddress);
        }

        owner.transfer(LISTING_FEE);
        nftListings[tokenID] = NFT(nftAddress, tokenID, msg.sender, price); 
        isListed[tokenID] = true;
        nftCount = nftCount + 1;

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
        nftCount = nftCount - 1;

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

        NFT memory nft = nftListings[tokenID];
        if(msg.value != nft.price) {
            revert ValueNotThePrice(nft.price);
        }

        sellerProceeds[nft.owner] += msg.value;
        delete(nftListings[tokenID]);
        isListed[tokenID] = false; 
        IERC721(nftAddress).safeTransferFrom(nft.owner, msg.sender, tokenID);

        emit ItemBought(msg.sender, nftAddress, nft.price);
    }

    function withdrawProceeds() public {
        uint256 proceeds = sellerProceeds[msg.sender];
        if(proceeds <= 0) {
            revert NoProceeds();
        }
        sellerProceeds[msg.sender] = 0;
        payable(msg.sender).transfer(proceeds);

        emit ProceedsWithdrawn(proceeds);
    }

     function getListedNfts() public view returns (NFT[] memory) {
        NFT[] memory nfts = new NFT[](nftCount);
        for (uint i = 0; i < nftCount; i++) {
            if (isListed[i] == true) {
                nfts[i] = nftListings[i];
            }
        }
        return nfts;
    }

    function getListing(uint256 tokenID) public view returns (NFT memory) {
        if (isListed[tokenID] != true) {
            revert ItemIsNotListed();
        }
        return nftListings[tokenID];
    }

    function viewProceeds(address seller) public view returns(uint256) {
        return sellerProceeds[seller];
    }
}
