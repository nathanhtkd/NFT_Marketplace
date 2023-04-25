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
    address payable public owner;  
    
    // Mapping of NFT token ID to its price
    mapping(uint256 => uint256) public nftPrices;   
    
    // Mapping of NFT token ID to its current owner
    mapping(uint256 => address) public nftOwners;

    // Mapping of NFT token ID to its current state (for sale or not)
    mapping(uint256 => bool) public nftForSale;

    uint256 public transactionFee;

    function listItem(address nftAddress, uint256 tokenID, uint256 price) public {

    }
}
    