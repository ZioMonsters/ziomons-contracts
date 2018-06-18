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
	}

	struct Defender {
		uint[5] deck;
		bool isDefending;
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

    function random ()
        internal
        pure
        returns(uint256)
    {
        seed = (4832897258932085 * seed + 34732894208) % 4325352;
        return seed;
    }
}
