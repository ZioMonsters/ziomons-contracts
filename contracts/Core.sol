pragma solidity ^0.4.24;

import "./Mortal.sol";
import "./Interfaces.sol";

contract Core is Mortal, ERC721, ERC165, ERC721Receiver {
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
	
}