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
        string memory _name,
        string memory _asset,
        string memory _category,
        string memory _type,
        address _sender
    ) external returns (uint256) {
        _index += 1;
        _tokens[_index] = TokenType(
            _index,
            _sender,
            _asset,
            _category,
            _type,
            _name
        );
        emit Transfer(address(0), _sender, _index);
        _balance[_sender] != 0 ? _balance[_sender] += 1 : _balance[_sender] = 1;
        return _index;
    }

    function ownerof(uint256 _id) external view returns (TokenType memory) {
        return _tokens[_id];
    }

    function balanceof(address _owner) public view returns (uint256) {
        return _balance[_owner];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        require(
            msg.sender == _tokens[_tokenId]._owner,
            "Only the owner of the token can initiate a transfer"
        );
        require(
            _from == _tokens[_tokenId]._owner,
            "The from address does not own the token"
        );
        require(_to != address(0), "Cannot transfer to the zero address");
        _tokens[_tokenId]._owner = _to;
        _balance[_from] -= 1;
        _balance[_to] += 1;
        emit Transfer(_from, _to, _tokenId);
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
        for (uint256 _indi = 1; _indi <= _index; _indi++) {
            if (_tokens[_indi]._owner == _own) {
                _toks[_idx] = _tokens[_indi];
                _idx += 1;
            }
        }
        return _toks;
    }

    function getContractAddress() public view returns (address) {
        return address(this);
    }
}
