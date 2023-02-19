// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./helpers/String.sol";
import "./types/TokenTypes.sol";
import "./events/Events.sol";

contract NFT is Events, Strings {
    uint256 private _index = 0;
    mapping(uint256 => TokenType) private _tokens;
    mapping(address => uint256) private _balance;

    function _mint(
        string memory _asset,
        string memory _category,
        string memory _type
    ) external returns (uint256) {
        _index += 1;
        _tokens[_index] = TokenType(
            _index,
            msg.sender,
            _asset,
            _category,
            _type
        );
        emit Transfer(address(0), msg.sender, _index);
        _balance[msg.sender] != 0
            ? _balance[msg.sender] += 1
            : _balance[msg.sender] = 1;
        return _index;
    }

    function ownerof(uint256 _id) external view returns (TokenType memory) {
        return _tokens[_id];
    }

    function balanceof(address _owner) public view returns (uint256) {
        return _balance[_owner];
    }

    function getTokens(
        address _own
    ) external view returns (TokenType[] memory) {
        uint256 count = balanceof(_own);
        if (count == 0) {
            return new TokenType[](0);
        }
        TokenType[] memory _toks = new TokenType[](count);
        uint256 _idx = 0;
        for (uint256 _indi = 1; _indi < _index; _indi++) {
            if (_tokens[_indi]._owner == _own) {
                _toks[_idx] = _tokens[_indi];
                _idx += 1;
            }
        }
        return _toks;
    }
}
