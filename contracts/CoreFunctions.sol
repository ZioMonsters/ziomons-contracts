pragma solidity ^0.4.24;

import "./Core.sol";

contract CoreFunctions is Core {

    function computeBattleResults(uint256 i, uint256 j, uint32[5] _ids) {
        //If it finds someone, the match starts.
        //First, it removes the defender from the list, and replaces it with the last element of the mapping.
        Defender memory _defender = waiting[i][j];
        delete waiting[i][j];
        //Length is reset
        waitingLength[i]--;
        waiting[i][j] = waiting[i][waitingLength[i]];

        //Resets the busy state of the defender's monsters. No for-loop is used to save gas.
        monsters[_defender.deck[0]].busy = false;
        monsters[_defender.deck[1]].busy = false;
        monsters[_defender.deck[2]].busy = false;
        monsters[_defender.deck[3]].busy = false;
        monsters[_defender.deck[4]].busy = false;

        //Then it computes the result of the match.
        uint256 _winnerId = startMatch(_ids, _defender.deck);

        //Converts the result from the startMatch functions into addresses and saves their bet
        address _winner;
        address _loser;
        uint256 _betWinner;
        uint256 _betLoser;
        if (_winnerId == 1) {
            _winner = msg.sender;
            _loser = _defender.addr;
            _betWinner = msg.value;
            _betLoser = _defender.bet;
        } else if (_winnerId == 2) {
            _winner = _defender.addr;
            _loser = msg.sender;
            _betWinner = _defender.bet;
            _betLoser = msg.value;
        } else {
            _winner = address(0);
        }

        //removes the defender's money from pending state.
        moneyPending = moneyPending.sub(_defender.bet);
        Team[5] memory _attackerTeam;
        Team[5] memory _defenderTeam;
        //creates _attackerTeam and _defenderTeam to be used on events. j is reused
        for (j = 0; j < 5; j++) {
            _attackerTeam[j] = Team(
                monsters[_ids[j]].atk,
                monsters[_ids[j]].def,
                monsters[_ids[j]].spd,
                _ids[j]
            );
            _defenderTeam[j] = Team(
                monsters[_defender.deck[j]].atk,
                monsters[_defender.deck[j]].def,
                monsters[_defender.deck[j]].spd,
                _defender.deck[j]
            );
        }

        //If it's a draw, give back the money to both opponents, without taking fees.
        if (_winner == address(0)) {
            money[_defender.addr] = money[_defender.addr].add(_defender.bet);
            money[msg.sender] = money[msg.sender].add(msg.value);

            //Emits the result. The squads are logged, together with the winnerBonus to allow
            //people to recreate the fight in case they want to.
            emit Results(
                msg.sender,
                _defender.addr,
                _attackerTeam,
                _defenderTeam,
                bonusWinner,
                _winnerId,
                _moneyWon
            );

            //The functions returns.
            return;

            //Otherwise, it computes the money won.
            uint256 _moneyWon;
        } else if (_defender.bet > msg.value) {
            _moneyWon = msg.value;
        } else {
            _moneyWon = _defender.bet;
        }

        //Gives back the unused money (if any) to the loser, and pays the winner, taking developer fees.
        uint256 _fees = calculateFees(_moneyWon);
        money[_winner] = money[_winner].add(_moneyWon).sub(_fees).add(_betWinner);
        money[_loser] = money[_loser].add(_betLoser).sub(_moneyWon);
        money[contractOwner] = money[contractOwner].add(_fees);

        //TODO Fees

        //Emits the result. The squads are logged, together with the winnerBonus to allow
        //people to recreate the fight in case they want to.
        emit Results(
            msg.sender,
            _defender.addr,
            _attackerTeam,
            _defenderTeam,
            bonusWinner,
            _winnerId,
            _moneyWon
        );

        //At the end, the function returns to prevent multiple fights
        return;
    }

    function startMatch(uint32[5] _team1Id, uint32[5] _team2Id)
        public /** TODO set to internal **/
    returns (uint)
    {
        uint256 _score1 = 0;
        uint256 _score2 = 0;

        Team[6] memory _team1;
        Team[6] memory _team2;

        for(i=0; i<5; i++){
            _team1[i] = Team(
                monsters[_team1Id[i]].atk,
                monsters[_team1Id[i]].def,
                monsters[_team1Id[i]].spd,
                0
            );

            _team2[i] = Team(
                monsters[_team2Id[i]].atk,
                monsters[_team2Id[i]].def,
                monsters[_team2Id[i]].spd,
                0
            );
        }

        for(uint256 i=0; i<5; i++) {
            if (_team1[i].spd > _team2[i].spd) {
                if(_team1[i].atk > _team2[i].def) {
                    _score1++;
                    _team1[i+1].atk+=bonusWinner;
                }
                else {
                    _score2++;
                    _team2[i+1].def+=bonusWinner;
                }
            } else if (_team1[i].spd < _team2[i].spd) {
                if(_team2[i].atk > _team1[i].def) {
                    _score2++;
                    _team2[i+1].atk+=bonusWinner;
                }
                else {
                    _score1++;
                    _team1[i+1].def+=bonusWinner;
                }
            } else {
                if (_team1[i].atk > _team2[i].atk) {
                    _score1++;
                    _team1[i+1].atk+=bonusWinner;
                }
                else if (_team1[i].atk < _team2[i].atk) {
                    _score2++;
                    _team2[i+1].def+=bonusWinner;
                }
                else {
                    if (_team1[i].def > _team2[i].def) {
                        _score1++;
                        _team1[i+1].def+=bonusWinner;
                    }
                    else if (_team1[i].def < _team1[i].def) {
                        _score2++;
                        _team2[i+1].def+=bonusWinner;
                    }
                    else {
                        expUp(_team1Id, _team2Id, true);
                        return 0;
                    }
                }
            }
        //if(score) //TODO FICX
        expUp(
            (_score1>_score2)? _team1Id:_team2Id,
            (_score1<_score2)? _team1Id:_team2Id,
            false
        );
        return (_score1 > _score2)? 1:2;
        }
    }

    function expUp(uint32[5] _team1Id, uint32[5] _team2Id, bool _draw)
        internal
    {
        uint256 _helpLoser = expUpLoser;
        if(_draw) _helpLoser = expUpWinner;

        for(uint256 i = 0; i<5; i++) {

            monsters[_team1Id[i]].exp = monsters[_team1Id[i]].exp.add(expUpWinner);
            monsters[_team2Id[i]].exp = monsters[_team2Id[i]].exp.add(_helpLoser);
        }
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
        if (_min == _max) return 0;
        return random() % (_max-_min) + _min;
    }

    function calculateFees(uint256 _price) internal view returns (uint256) {
        return _price.mul(fees) / 10000;
    }
}
