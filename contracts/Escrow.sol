// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarketplaceEscrow {
    address public owner;
    uint256 public feePercent;

    struct Escrow {
        address buyer;
        address seller;
        address nftAddress;
        uint256 tokenId;
        uint256 price;
        bool isComplete;
    }

    mapping(uint256 => Escrow) public escrows;
    uint256 public nextEscrowId;

    event EscrowCreated(uint256 indexed escrowId, address indexed buyer, address indexed seller, address nftAddress, uint256 tokenId, uint256 price);
    event EscrowCompleted(uint256 indexed escrowId);

    constructor(uint256 _feePercent) {
        owner = msg.sender;
        feePercent = _feePercent;
    }

    function createEscrow(address _seller, address _nftAddress, uint256 _tokenId, uint256 _price) external payable {
        require(msg.value == _price, "Payment must be equal to the price");
        
        escrows[nextEscrowId] = Escrow(msg.sender, _seller, _nftAddress, _tokenId, _price, false);
        emit EscrowCreated(nextEscrowId, msg.sender, _seller, _nftAddress, _tokenId, _price);
        
        nextEscrowId++;
    }

    function completeEscrow(uint256 _escrowId) external {
        Escrow storage escrow = escrows[_escrowId];
        require(msg.sender == escrow.buyer, "Only buyer can complete the escrow");
        require(!escrow.isComplete, "Escrow is already completed");

        IERC721(escrow.nftAddress).transferFrom(escrow.seller, escrow.buyer, escrow.tokenId);

        uint256 fee = calculateFee(escrow.price);
        payable(owner).transfer(fee);
        payable(escrow.seller).transfer(escrow.price - fee);

        escrow.isComplete = true;
        emit EscrowCompleted(_escrowId);
    }

    function calculateFee(uint256 _amount) private view returns (uint256) {
        return (_amount * feePercent) / 100;
    }
}
