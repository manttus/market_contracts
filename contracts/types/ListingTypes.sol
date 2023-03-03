// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./TokenTypes.sol";

struct ListingType {
    uint256 _id;
    uint256 _price;
    TokenType _token;
    bool _active;
}
