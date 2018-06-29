pragma solidity ^0.4.24;

import "./Core.sol";


contract CoreFunctions is Core {

    function firstLogin() internal {
        if (balances[msg.sender] == 0)
            isWaiting[msg.sender] = [100, 0];
    }

    function computeBattleResults(uint256 i, uint256 j, uint32[5] _ids)
        internal
    {
        //If it finds someone, the match starts.
        //First, it removes the defender from the list, and replaces it with the last element of the mapping.
        Defender memory _defender = waiting[i][j];

        //Length and waiting state are reset
        waitingLength[i]--;
        waiting[i][j] = waiting[i][waitingLength[i]];
        isWaiting[_defender.addr] = [100, 0];

        //Builds data array, used for event logging.
        uint32[20] memory _team1;
        uint32[20] memory _team2;
        for (i = 0; i < 5; i++) {
            _team1[i] = _ids[i];
            _team1[i+5] = uint32(monsters[_ids[i]].atk);
            _team1[i+10] = uint32(monsters[_ids[i]].def);
            _team1[i+15] = uint32(monsters[_ids[i]].spd);
            _team2[i] = _defender.deck[i];
            _team2[i+5] = uint32(monsters[_defender.deck[i]].atk);
            _team2[i+10] = uint32(monsters[_defender.deck[i]].def);
            _team2[i+15] = uint32(monsters[_defender.deck[i]].spd);
        }

        //Resets the busy state of the defender"s monsters.
        for (i = 0; i < 5; i++)
            monsters[_defender.deck[i]].busy = false;

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

            //If it"s a draw, give back the money to both opponents, without taking fees.
        } else {
            money[_defender.addr] = money[_defender.addr].add(_defender.bet);
            money[msg.sender] = money[msg.sender].add(msg.value);

            //Emits the result. The squads are logged, together with the winnerBonus to allow
            //people to recreate the fight in case they want to.
            emit Results(
                msg.sender,
                _defender.addr,
                _team1,
                _team2,
                uint8(params[11]),
                _winnerId,
                _moneyWon
            );

            //The functions returns.
            return;

        }

            //Otherwise, it computes the money won.
        uint256 _moneyWon;
        if (_defender.bet > msg.value) {
            _moneyWon = msg.value;
        } else {
            _moneyWon = _defender.bet;
        }

        //Gives back the unused money (if any) to the loser, and pays the winner, taking developer fees.
        uint256 _fees = _moneyWon.mul(params[9])/10000;
        money[_winner] = money[_winner].add(_moneyWon).sub(_fees).add(_betWinner);
        money[_loser] = money[_loser].add(_betLoser).sub(_moneyWon);
        money[contractOwner] = money[contractOwner].add(_fees);

        //Emits the result. The squads are logged, together with the winnerBonus to allow
        //people to recreate the fight in case they want to.
        emit Results(
            msg.sender,
            _defender.addr,
            _team1,
            _team2,
            uint8(params[11]),
            _winnerId,
            _moneyWon
        );

        //At the end, the function returns to prevent multiple fights
        return;
    }

    function startMatch(uint32[5] _team1Id, uint32[5] _team2Id)
        internal
        view
        returns (uint256)
    {
        uint256 _score1 = 0;
        uint256 _score2 = 0;

        Team[6] memory _team1;
        Team[6] memory _team2;

        for (uint256 i = 0; i < 5; i++) {
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

        for (i = 0; i < 5; i++) {
            if (_team1[i].spd > _team2[i].spd) {
                if (_team1[i].atk > _team2[i].def) {
                    _score1++;
                    _team1[i+1].atk += uint8(params[11]);
                } else {
                    _score2++;
                    _team2[i+1].def += uint8(params[11]);
                }
            } else if (_team1[i].spd < _team2[i].spd) {
                if (_team2[i].atk > _team1[i].def) {
                    _score2++;
                    _team2[i+1].atk += uint8(params[11]);
                } else {
                    _score1++;
                    _team1[i+1].def += uint8(params[11]);
                }
            } else {
                if (_team1[i].atk > _team2[i].atk) {
                    _score1++;
                    _team1[i+1].atk += uint8(params[11]);
                } else if (_team1[i].atk < _team2[i].atk) {
                    _score2++;
                    _team2[i+1].def += uint8(params[11]);
                } else {
                    if (_team1[i].def > _team2[i].def) {
                        _score1++;
                        _team1[i+1].def += uint8(params[11]);
                    } else if (_team1[i].def < _team1[i].def) {
                        _score2++;
                        _team2[i+1].def += uint8(params[11]);
                    } else {
                        expUp(_team1Id, _team2Id, true);
                        return 0;
                    }
                }
            }
        }
        
        expUp(
            (_score1 > _score2) ? _team1Id : _team2Id,
            (_score1 < _score2) ? _team1Id : _team2Id,
            false
        );
        return (_score1 > _score2) ? 1 : 2;
    }

    function expUp(uint32[5] _team1Id, uint32[5] _team2Id, bool _draw)
        internal
    {
        for (uint256 i = 0; i < 5; i++) {
            if (monsters[_team1Id[i]].lvl < 100)
                monsters[_team1Id[i]].exp = monsters[_team1Id[i]].exp + params[7];
            if (monsters[_team2Id[i]].lvl < 100)
                monsters[_team2Id[i]].exp = monsters[_team2Id[i]].exp + (_draw ? params[7] : params[8]);
        }
    }

    function randInt(uint256 _min, uint256 _max)
        internal
        returns(uint256)
    {
        seed = (45673657420947598375958743997 * seed + 359873489578437507340985340985347) % 984732984732897443257676352;
        if (_min == _max)
            return 0;
        else
            return seed % (_max-_min) + _min;
    }
}
