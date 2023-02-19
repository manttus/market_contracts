// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract Strings {
    function getLength(string memory _str) public pure returns (uint256) {
        bytes memory _bytes = bytes(_str);
        return _bytes.length;
    }
}
