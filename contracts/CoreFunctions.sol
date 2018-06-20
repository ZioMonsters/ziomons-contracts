pragma solidity ^0.4.24;

import "./Core.sol";

contract CoreFunctions is Core {

    function startMatch(uint256[5] _team1Id, uint256[5] _team2Id)
        public /** TODO set to internal **/
    returns (uint)
    {
        uint256 _score1 = 0;
        uint256 _score2 = 0;

        tmpTeam[6] memory _team1;
        tmpTeam[6] memory _team2;

        for(i=0; i<5; i++){
            _team1[i] = tmpTeam(
                monsters[_team1Id[i]].atk,
                monsters[_team1Id[i]].def,
                monsters[_team1Id[i]].spd
            );

            _team2[i] = tmpTeam(
                monsters[_team2Id[i]].atk,
                monsters[_team2Id[i]].def,
                monsters[_team2Id[i]].spd
            );
        }

        for(uint256 i=0; i<5; i++) {
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

    function random() internal returns(uint256) {
        seed = (456736574209475983759587439975973457287552780923 * seed + 35987348957843750734098534098534732894208) % 498327498732984732984732897443257676352;
        return seed;
    }

    function randInt(uint256 _min, uint256 _max) internal returns(uint256) {
        return random() % (_max-_min) + _min;
    }
}