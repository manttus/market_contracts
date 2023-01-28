// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract Market {
    // public - anyone can call
    // private - only this contract can call
    // internal - only this contract and inheriting contracts
    // external - only external calls

    // function can read and write
    // view - read-only
    // pure - no read, no write

    enum LisitingStatus {
        Active,
        Sold,
        Cancelled
    }

    struct Listing {
        address seller;
        address token;
        uint256 tokenId;
        uint price;
        LisitingStatus status;
    }

    uint256 public _indi = 0;

    mapping(uint256 => Listing) private _listings;

    event Listed(
        uint256 listingId,
        address seller,
        address token,
        uint tokenId,
        uint price
    );

    event Sale(
        uint256 listingId,
        address buyer,
        address token,
        uint tokenId,
        uint price
    );

    event Cancel(uint256 listingId, address seller);

    function getListing(
        uint256 listingId
    ) public view returns (Listing memory) {
        return _listings[listingId];
    }

    function addToList(address token, uint256 tokenId, uint256 price) external {
        IERC721(token).transferFrom(msg.sender, address(this), tokenId);
        Listing memory listing = Listing(
            msg.sender,
            token,
            tokenId,
            price,
            LisitingStatus.Active
        );
        _indi += 1;
        _listings[1] = listing;

        emit Listed(_indi, msg.sender, token, tokenId, price);
    }

    function buyToken(uint indi) external payable {
        Listing storage listing = _listings[indi];
        require(
            listing.status == LisitingStatus.Active,
            "Listing is not active"
        );
        require(msg.sender != listing.seller, "Seller Cannot be buyer");
        msg.value;
        require(msg.value >= listing.price, "Insufficient fund");
        IERC721(listing.token).transferFrom(
            address(this),
            msg.sender,
            listing.tokenId
        );
        payable(listing.seller).transfer(listing.price);

        emit Sale(
            _indi,
            msg.sender,
            listing.token,
            listing.tokenId,
            listing.price
        );
    }

    function cancel(uint256 indi) public {
        Listing storage listing = _listings[indi];
        require(
            listing.status == LisitingStatus.Active,
            "Listing is not Active"
        );
        require(msg.sender == listing.seller, "Only Seller can cancel listing");
        listing.status = LisitingStatus.Cancelled;
        IERC721(listing.token).transferFrom(
            address(this),
            msg.sender,
            listing.tokenId
        );

        emit Cancel(indi, msg.sender);
    }
}
