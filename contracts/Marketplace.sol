// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./types/TokenTypes.sol";
import "./NFT.sol";
import "./events/Events.sol";
import "./types/ListingTypes.sol";

contract Market is Events {
    NFT private _nftContract;
    uint256 private _index = 0;

    constructor(address nftAddress) {
        _nftContract = NFT(nftAddress);
    }

    mapping(uint256 => ListingType) private _listing;

    function createListing(uint256 tokenId, uint256 price) external {
        require(
            _nftContract.ownerof(tokenId)._owner == msg.sender,
            "No Token Minted!"
        );
        _index += 1;
        _listing[_index] = ListingType(
            _index,
            price,
            _nftContract.ownerof(tokenId),
            true
        );
    }

    function cancelListing(uint256 _listingId) external {
        ListingType storage list = _listing[_listingId];
        require(list._active, "NFT not Listed");
        require(list._token._owner == msg.sender, "You are not the seller");
        list._active = false;
    }

    function buyToken(uint256 _listingId) external payable {
        ListingType storage list = _listing[_listingId];
        require(list._active, "NFT not Listed");
        require(msg.value >= list._price, "Insufficient Balance");
        _nftContract.transferFrom(
            list._token._owner,
            msg.sender,
            list._token._id
        );
    }

    function editListing(uint256 _listingId, uint256 newPrice) external {
        ListingType storage list = _listing[_listingId];
        require(list._active, "NFT not Listed");
        require(list._token._owner == msg.sender, "You are not the seller");
        list._price = newPrice;
    }
}
