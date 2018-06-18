pragma solidity ^0.4.24;

import "./Interfaces.sol";
import "./State.sol";

contract Core is State, ERC721, ERC165, ERC721Receiver {

	enum Rarity {common, rare, epic, legendary}

	struct Monster {
		uint8 atk;
		uint8 def;
		uint8 spd;
		uint8 lvl;
		uint16 exp;
		Rarity rarity;
<<<<<<< HEAD
	}

	struct Defender {
		uint[5] deck;
		bool isDefending;
=======
>>>>>>> 00a535849d1b629c2e488d0db0f1b8b960897589
	}

	Monster[] monsters;
	mapping(uint256 => address) owner;
	mapping(address => uint256) balance;
	mapping(address => mapping(address => bool)) approvedForAll;
	mapping(uint256 => address) approved;
	mapping(address => Defender) onDefence;

	mapping(uint256 => uint256) inSale;

	modifier isAuthorized(address _sender, uint256 _id) {
		require(
			owner[_id] == _sender ||
			approved[_id] == _sender ||
			approvedForAll[owner[_id]][_sender]
		);
		_;
	}
}
