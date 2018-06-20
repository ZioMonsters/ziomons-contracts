pragma solidity ^0.4.24;

import "./Interfaces.sol";
import "./State.sol";

contract Core is State, ERC721, ERC165, ERC721Receiver {
	using SafeMath for uint8;

	enum Rarity {common, uncommon, epic, legendary}

	struct Monster {
		uint8 atk;
		uint8 def;
		uint8 spd;
		uint8 lvl;
		uint16 exp;
		Rarity rarity;
        uint32 genome;
	}

	struct Defender {
		uint256[5] deck;
    uint256 bet;
    uint8 level;
    bool defending;
	}

	Monster[] public monsters;
	mapping(uint256 => address) owner;
	mapping(address => uint256) balances;
	mapping(address => mapping(address => bool)) approvedForAll;
	mapping(uint256 => address) approved;
	mapping(address => uint256) money;
    mapping(address => Defender) public onDefence; //TODO remove public

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

	struct tmp {
		uint8 atk;
		uint8 def;
		uint8 spd;
	}

    function startMatch(uint256[5] _team1Id, uint256[5] _team2Id)
			public /** TODO set to internal **/
			returns (uint)
		{
			uint256 _score1 = 0;
			uint256 _score2 = 0;
			uint256 i;

			tmp[6] memory _team1;
			tmp[6] memory _team2;

			for(i=0; i<5; i++){
				_team1[i] = tmp(
					monsters[_team1Id[i]].atk,
					monsters[_team1Id[i]].def,
					monsters[_team1Id[i]].spd
				);

					_team2[i] = tmp(
						monsters[_team1Id[i]].atk,
						monsters[_team1Id[i]].def,
						monsters[_team1Id[i]].spd
					);
			}

			for(i=0; i<5; i++) {
				if (_team1[i].spd > _team2[i].spd) {
					if(_team1[i].atk > _team2[i].def) {
						_score1++;
						_team1[i+1].atk++;
					}
					else {
						_score2++;
						_team2[i+1].def++;
					}
				} else if (_team1[i].spd < _team2[i].spd) {
					if(_team1[i].atk > _team2[i].atk) {
						_score2++;
						_team2[i+1].atk++;
					}
					else {
						_score1++;
						_team1[i+1].def++;
					}
				} else {
					if (_team1[i].atk > _team2[i].atk) {
						_score1++;
						_team1[i+1].atk++;
					}
					else if (_team1[i].atk < _team2[i].atk) {
						_score2++;
						_team2[i+1].def++;
					}
					else {
						if (_team1[i].def > _team2[i].def) {
							_score1++;
							_team1[i+1].def++;
						}
						else if (_team1[i].def < _team1[i].def) {
							_score2++;
							_team2[i+1].def++;
						}
					 //else tied, same monster, no points
					}
				}
			}
			/* TODO lvlUp */
			return (_score1 > _score2)? 1:(_score1 < _score2)? 2:0;
		}

    function notDuplicate(uint256[5] _ids) internal returns(bool) {
        for (uint256 i = 0; i < 5; i++) {
            for (uint256 j = 0; j < 5; j++) {
                if (_ids[i] == _ids[j] && j != i)
                    return false;
            }
        }
        return true;
    }

    function random() public returns(uint256) {
        seed = (456736574209475983759587439975973457287552780923 * seed + 35987348957843750734098534098534732894208) % 498327498732984732984732897443257676352;
        return seed;
    }

	function randInt(uint256 _min, uint256 _max) public returns(uint256) {
		return random() % (_max-_min) + _min;
	}

    uint prime = 4294967291;
    event T(uint _n);

    function NRrandInt(uint _x) internal returns(uint) {
        return NRRandom((NRRandom(_x) + 92837498) ^ 0x5bf03635);
    }

    function NRRandom(uint _i) private returns(uint){
        if (_i >= prime) return _i;
        uint residue = (_i*_i) % prime;
        return (_i <= prime / 2) ? residue : prime - residue;
    }
}
