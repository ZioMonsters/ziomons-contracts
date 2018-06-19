pragma solidity ^0.4.24;

import "./Interfaces.sol";
import "./State.sol";

contract Core is State, ERC721, ERC165, ERC721Receiver {
	using SafeMath for uint8;

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
		Monster[5] deck;
		bool isDefending;
		uint256 bet;
		uint256 averageLvl;
	}

	Monster[] monsters;
	mapping(uint256 => address) owner;
	mapping(address => uint256) balance;
	mapping(address => mapping(address => bool)) approvedForAll;
	mapping(uint256 => address) approved;
	mapping(address => Defender) onDefence;

	mapping(uint256 => uint256) inSale;
    uint256 seed;

	modifier isAuthorized(address _sender, uint256 _id) {
		require(
			owner[_id] == _sender ||
			approved[_id] == _sender ||
			approvedForAll[owner[_id]][_sender]
		);
		_;
	}

    function startMatch(Monster[5] _team1, Monster[5] _team2)
			internal
			returns (uint)
		{
			uint256 _score1 = 0;
			uint256 _score2 = 0;
			uint256 i = 0;

			for(i=0; i<5; i++){
				if (_team1[i].spd > _team2[i].spd) {
					if(_team1[i].atk > _team2[i].def) _score1 = _score1.add(1);
					else _score2 = _score2.add(1);
				} else if (_team1[i].spd < _team2[i].spd) {
					if(_team2[i].atk > _team1[i].def) _score2 = _score2.add(1);
					else _score1 = _score1.add(1);
				} else {
					if (_team1[i].atk > _team2[i].atk) _score1 = _score1.add(1);
					else if (_team1[i].atk < _team2[i].atk) _score2 = _score2.add(1);
					else {
						if (_team1[i].def > _team2[i].def) _score1 = _score1.add(1);
						else if (_team1[i].def < _team2[i].def) _score2 = _score2.add(1);
					 //else tied, same monster, no points
					}
				}
			}

			return (_score1 > _score2)? 1: (_score1 < _score2)? 2:0;
		}

    function random()
        internal
        returns(uint256)
    {
        seed = (4832897258932085 * seed + 34732894208) % 4325352;
        return seed;
    }
}
