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

    mapping(uint256 => ListingType) public _listing;

    function _createListing(uint256 tokenId, uint256 price) external {
        require(
            _nftContract._ownerOf(tokenId)._owner == msg.sender,
            "No Token Minted!"
        );
        _index += 1;
        _listing[_index] = ListingType(
            _index,
            price,
            _nftContract._ownerOf(tokenId),
            true
        );
    }

    function _cancelListing(uint256 _listingId) public {
        ListingType storage list = _listing[_listingId];
        require(list._active, "NFT not Listed");
        require(list._token._owner == msg.sender, "You are not the seller");
        list._active = false;
    }

    function _buyToken(uint256 _listingId, address buyer) external payable {
        ListingType storage list = _listing[_listingId];
        require(list._active, "NFT not Listed");
        require(msg.value >= list._price, "Insufficient Balance");
        _nftContract._transferFrom(list._token._owner, buyer, list._token._id);
        _editListing(list._token._id, _listingId, buyer, list._price, false);
    }

    function _getListings() public view returns (ListingType[] memory) {
        ListingType[] memory _toks = new ListingType[](_index);
        uint256 _idx = 0;
        for (uint256 _indi = 1; _indi <= _index; _indi++) {
            if (_listing[_indi]._active) {
                _toks[_idx] = _listing[_indi];
            }
        }
        return _toks;
    }

    function _editListing(
        uint256 _tokenId,
        uint256 _listingId,
        address _owner,
        uint256 newPrice,
        bool _isListed
    ) public {
        ListingType storage list = _listing[_listingId];
        require(list._active, "NFT not Listed");
        require(
            _nftContract._ownerOf(_tokenId)._owner == _owner,
            "You are not the seller"
        );
        list._active = _isListed;
        list._price = newPrice;
        list._token._owner = _owner;
    }
}
