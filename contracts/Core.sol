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
		Monster[5] deck;
		bool isDefending;
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
			returns (uint[5])
		{
			uint8[5] _results;
			uint _score1 = 0;
			uint8 _score2 = 0;
			uint8 i = 0;

			for(i=0; i<5; i++){
				if (_team1[i].spd > _team2[i].spd) {
					if(_team1[i].atk > _team2[i].def) _results.push(1);
					else _results.push(2);
				} else if (_team1[i].spd < _team2[i].spd) {
					if(_team2[i].atk > _team1[i].def) _results.push(2);
					else _results.push(1);
				} else {
					if (_team1[i].atk > _team2[i].atk) _results.push(1);
					else if (_team1[i].atk < _team2[i].atk) _results.push(2);
					else {
						if (_team1[i].def > _team2[i].def) _results.push(1);
						else if (_team1[i].def < _team2[i].def) _results.push(2);
						else _results.push(0);  //tied, same monster
					}
				}
			}
		}

    function random()
        internal
        returns(uint256)
    {
        seed = (4832897258932085 * seed + 34732894208) % 4325352;
        return seed;
    }
}
