// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    How does an nft contract interact with the marketplace?
*/

// NFT standard is ERC721
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// reentrant guard 
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {

    address public owner;  
    
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
        owner = msg.sender;
        transactionFee = 100;
    }

    function listItem(address nftAddress, uint256 tokenID, uint256 price) public payable nonReentrant {
        require(price > 0, 'Price needs to be greater than 0');
        require(msg.value == transactionFee, 'Please include the transaction fee');
        IERC721(nftAddress).transferFrom(msg.sender, address(this), tokenID);
        nftListings[tokenID] = NFT(nftAddress, tokenID, msg.sender, price); 
        isListed[tokenID] = true;
    }

    function unlistItem(address nftAddress, uint256 tokenID) public {
        require(isListed[tokenID] == true, 'Not listed');
        require(nftListings[tokenID].owner == msg.sender, 'Not your nft');
        IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenID);
        isListed[tokenID] = false;
    }

    function buyNft(address nftAddress, uint256 tokenID) public payable nonReentrant {
        require(isListed[tokenID] == true, 'Not listed');
        NFT storage nft = nftListings[tokenID];
        require(msg.value == nft.price, "Not enough money");
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
    