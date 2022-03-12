// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;
pragma abicoder v2;

/**
 * @dev {ERC721} token, including:
 */
interface IPiratesKingBase {
    struct PKChest {
        uint256 tokenId;
        string tokenURI;
        address payable mintedBy;
        address payable currentOwner;
        address payable previousOwner;
        uint256 price;
        uint256 numberOfTransfers;
        bool forSale;
        bool isOpened;
        string data;
        uint8 cType; // chest token uri
    }
}
