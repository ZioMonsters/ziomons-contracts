pragma solidity ^0.4.24;

import "./Interfaces.sol";

contract Core is State, ERC721, ERC165, ERC721Receiver {
	struct Monster {
		uint8 atk;
		uint8 def;
		uint8 spd;
		uint8 lvl;
		uint16 exp;
		uint8 rarity;
		uint8 energy;
	}

	Monster[] monsters;
	mapping(uint256 => address) owner;
	mapping(address => uint256) balance;
	mapping(address => mapping(address => bool)) approvedForAll;
	mapping(uint256 => address) approved;

	modifier isAuthorized(address _sender, uint256 _id) {
		require(
			owner[_id] == sender ||
			approved[_id] == _sender ||
			approvedForAll[owner[_id]][_sender];
		)
	}
}