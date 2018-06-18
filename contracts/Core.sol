pragma solidity ^0.4.24;

import "./Mortal.sol";
import "./Interfaces.sol";

contract Core is Mortal, ERC721, ERC165, ERC721Receiver {

	enum Rarity {common, rare, epic, legendary}

	struct Monster {
		uint8 atk;
		uint8 def;
		uint8 spd;
		uint8 lvl;
		uint16 exp;
		Rarity rarity;
		uint8 energy;
	}

	Monster[] monsters;
	mapping(uint256 => address) owner;
	mapping(address => uint256) balance;
	mapping(address => mapping(address => bool)) approvedForAll;
	mapping(address => mapping(uint256 => address)) approved;
	mapping(uint => mapping(address => address)) tokenIdToApprovedAddress;



}
