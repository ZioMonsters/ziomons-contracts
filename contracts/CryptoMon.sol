pragma solidity ^0.4.24;

import "./AdminPanel.sol";
import "./SafeMath.sol";


contract CryptoMon is AdminPanel {

    using SafeMath for uint8;

    constructor() public {
        seed = now;
    }

    function unbox()
        external
        payable
    {
        uint256 _modifier;
        if (msg.value >= params[2]) {
            _modifier = params[5];
        } else if (msg.value >= params[1]) {
            _modifier = params[4];
        } else if (msg.value >= params[0]) {
            _modifier = params[3];
        } else {
            revert();
        }

        firstLogin();

        for (uint8 i = 0; i < 6; i++) {
            owner[monsters.length] = msg.sender;
            uint256 _tmp = randInt(0, 1000-_modifier);
            uint256 _modRarityMin;
            uint256 _modRarityMax;
            uint8 _rarity;

            if (_tmp == 1) {
                _modRarityMin = 17;
                _modRarityMax = 21;
                _rarity = 3;
            } else if (_tmp < 11) {
                _modRarityMin = 14;
                _modRarityMax = 17;
                _rarity = 2;
            } else if (_tmp < 200) {
                _modRarityMin = 11;
                _modRarityMax = 14;
                _rarity = 1;
            } else {
                _modRarityMin = 8;
                _modRarityMax = 11;
                _rarity = 0;
            }

            monsters.push(
                Monster(
                    uint8(randInt(_modRarityMin, _modRarityMax)),
                    uint8(randInt(_modRarityMin, _modRarityMax)),
                    uint8(randInt(_modRarityMin, _modRarityMax)),
                    1,
                    _rarity,
                    0,
                    false
                )
            );

            emit Transfer(address(0), msg.sender, monsters.length);
        }

        balances[msg.sender] = balances[msg.sender].add(6);
        money[contractOwner] = money[contractOwner].add(msg.value);
    }

    function fight(uint32[5] _ids, uint256 _minBet)
        external
        payable
    {
        //Check that you actually payed at least your minimum bet and that you are not already waiting.
        require(msg.value >= _minBet && isWaiting[msg.sender][0] == 100);
        for (uint256 i = 0; i < 5; i++) {
            //Check that you own all of the monsters you want to use to attack and that they aren't busy
            require(owner[_ids[i]] == msg.sender && !monsters[_ids[i]].busy);
            for (uint256 j = 0; j < 5; j++) {
                //check that there aren't any duplicates in your squad
                require(_ids[i] != _ids[j] || i == j);
            }
        }

        //Sets the matchmaking level.
        uint256 _level;
        uint8[5] memory _tmp;
        for (i = 0; i < 5; i++)
            _tmp[i] = monsters[_ids[i]].lvl;

        //Insertion sort algorithm
        for (i = 1; i < 5; i++) {
            uint8 temp = _tmp[i];
            for (j = i - 1; j >= 0 && temp < _tmp[j]; j--)
                _tmp[j+1] = _tmp[j];
            _tmp[j + 1] = temp;
        }

        //The waiting queue has only 100 spaces, this means that its last index is 99, not 100.
        _level = _tmp[2] - 1;

        //Used to prevent underflow. More efficient than doing other checks
        if (_level < params[6])
            _level = params[6];

        //Checks for every level in range.
        for (i = _level - params[6]; i <= _level + params[6] && i < 100; i++) {

            //Skips current range to save gas and prevent errors when using %0
            if (waitingLength[i] == 0)
                continue;

            //Checks for every person in the current waiting level to find someone who has the same bet range as you.
            //Starts to check from a random position in the array, to prevent unlucky people from never playing.
            //Note that waiting is an array of mappings, this is because arrays are broken, and .length is not
            //reset after deleting the last element.
            uint256 _start = randInt(0, waitingLength[i]);
            for (j = _start; j < waitingLength[i] + _start; j++) {
                //j needs to be "modulized", to loop back in front of the array.
                uint256 j_ = j % waitingLength[i];

                //If it finds someone the fight starts and the functions returns.
                if (
                    waiting[i][j_].minBet <= msg.value &&
                    waiting[i][j_].bet >= _minBet &&
                    waiting[i][j_].addr != msg.sender
                )
                    return computeBattleResults(i, j_, _ids);
            }
        }

        //If the contract couldn"t find anyone, it puts you in the waiting list.
        //All of your monsters are marked as busy.
        for (i = 0; i < 5; i++)
            monsters[_ids[0]].busy = true;

        waiting[_level][waitingLength[_level]] = Defender(
            msg.sender,
            _ids,
            _minBet,
            msg.value
        );

        waitingLength[_level]++;

        //Sets waiting state
        isWaiting[msg.sender] = [_level, waitingLength[_level] - 1];
    }

    function stopWaiting()
        external
    {
        uint256 _x = isWaiting[msg.sender][0];
        require(_x != 100);
        uint256 _y = isWaiting[msg.sender][1];

        money[waiting[_x][_y].addr] = money[waiting[_x][_y].addr].add(waiting[_x][_y].bet);

        for (uint256 i = 0; i < 5; i++)
            monsters[waiting[_x][_y].deck[i]].busy = false;

        waiting[_x][_y] = waiting[_x][waitingLength[_x] - 1];
        waitingLength[_x]--;
        isWaiting[msg.sender] = [100, 0];
    }

    function sellMonster(
        uint32 _id,
        uint256 _price
    )
        external
    {
        require((!monsters[_id].busy || inSale[_id] > 0) && owner[_id] == msg.sender);
        inSale[_id] = _price;
        monsters[_id].busy = (_price == 0) ? false : true;
        emit ForSale(msg.sender, _id, _price);
    }

    function buyMonster(uint32 _id)
        external
        payable
    {
        require(inSale[_id] > 0 && msg.value >= inSale[_id]);
        inSale[_id] = 0;
        address owner_ = owner[_id];

        uint256 _fees = msg.value.mul(params[9]) / 10000;
        money[owner_] = money[owner_].add(msg.value).sub(_fees);
        money[contractOwner] = money[contractOwner].add(_fees);

        approved[_id] = msg.sender;
        emit Approval(owner_, msg.sender, _id);

        monsters[_id].busy = false;

        transferFrom(owner_, msg.sender, _id);
    }

    function withdraw()
        external
        returns(uint)
    {
        require(money[msg.sender] > 0);
        uint256 _amount = money[msg.sender];
        money[msg.sender] = 0;
        msg.sender.transfer(_amount);
        return _amount;
    }

    function lvlUp (
        uint32[] _ids,
        uint8[] _atkMod,
        uint8[] _defMod,
        uint8[] _spdMod
    )
        external
    {
        require(
            _ids.length == _atkMod.length &&
            _atkMod.length == _defMod.length &&
            _defMod.length == _spdMod.length
        );

        uint8 _skillsAvailable;

        for (uint256 i = 0; i < _ids.length; i++) {
            _skillsAvailable = 0;
            require(owner[_ids[i]] == msg.sender);

            while (
                ((uint256(monsters[_ids[i]].lvl)**3)/5) <= monsters[_ids[i]].exp &&
                monsters[_ids[i]].lvl < 100
            ) {
                monsters[_ids[i]].lvl++;
                _skillsAvailable += uint8(params[10]);
            }


            require(_atkMod[i] + _defMod[i] + _spdMod[i] <= _skillsAvailable);

            uint256 _cap = monsters[_ids[i]].lvl/11*12+20;

            require(
                _cap >= monsters[_ids[i]].atk+_atkMod[i] &&
                _cap >= monsters[_ids[i]].def+_defMod[i] &&
                _cap >= monsters[_ids[i]].spd+_spdMod[i]
            );
            monsters[_ids[i]].atk += _atkMod[i];
            monsters[_ids[i]].def += _defMod[i];
            monsters[_ids[i]].spd += _spdMod[i];
        }
        emit Upgraded(
            _ids,
            _atkMod,
            _defMod,
            _spdMod
            );
    }
}
