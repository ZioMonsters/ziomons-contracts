pragma solidity ^0.4.24;

import "./AdminPanel.sol";
import "./SafeMath.sol";

contract CryptoMon is AdminPanel {

using SafeMath for uint8;

    constructor() public {
        seed = now;
    }

	function unbox()
		public
		payable
		running
		returns(uint256[6])
	{
        uint256 _modifier;
        if (msg.value >= maxiBoxPrice)
            _modifier = modifierMaxi;
        else if (msg.value >= plusBoxPrice)
            _modifier = modifierPlus;
        else if (msg.value >= standardBoxPrice)
            _modifier = modifierStandard;
        else
            revert();

        uint256[6] memory _ids;

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
                false,
                "" //TODO add name
            )
        );

      _ids[i] = monsters.length - 1;
      emit Transfer(address(0), msg.sender, monsters.length);
    }
        balances[msg.sender] = balances[msg.sender].add(6);
        money[contractOwner] = money[contractOwner].add(msg.value);

        emit Unboxed(msg.sender, _ids);
        return _ids;
	}

    function fight(uint32[5] _ids, uint256 _minBet) public payable running{
        //Check that you actually payed at least your minimum bet
        require(msg.value >= _minBet);
        for (uint256 i = 0; i < 5; i++) {
            //Check that you own all of the monsters you want to use to attack and that they aren't busy
            require(owner[_ids[i]] == msg.sender && !monsters[_ids[i]].busy);
            for (uint256 j = 0; j < 5; j++) {
                //check that there aren't any duplicates in your squad
                require(_ids[i] != _ids[j] || i == j);
            }
        }

        //Sets the matchmaking level. TODO: matchmaking using median
        for (i = 0; i < 5; i++)
            if (monsters[_ids[i]].lvl > _level)
                uint256 _level = monsters[_ids[i]].lvl;

        //The waiting queue has only 100 spaces, this means that its last index is 99.
        _level--;

        //Used to prevent underflows. More efficient than doing other checks
        if (_level < matchmakingRange)
            _level = matchmakingRange;

        //Checks for every level in range.
        for (i = _level - matchmakingRange; i <= _level + matchmakingRange && i < 100; i++) {

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
                    waiting[i][j_].bet >= _minBet
                ) return computeBattleResults(i, j_, _ids);
            }
        }

        //If the contract couldn't find anyone, it puts you in the waiting list and puts your money
        //In pending state. All of your monsters are marked as busy. Again, a for loop isn't used to
        //save gas.
        monsters[_ids[0]].busy = true;
        monsters[_ids[1]].busy = true;
        monsters[_ids[2]].busy = true;
        monsters[_ids[3]].busy = true;
        monsters[_ids[4]].busy = true;
        waiting[_level][waitingLength[_level]] = Defender(
            msg.sender,
            _ids,
            _minBet,
            msg.value,
            uint8(_level)
        );

        waitingLength[_level]++;
        moneyPending= moneyPending.add(msg.value);
    }


    function sellMonster(
		uint256 _id,
		uint256 _price
	)
		public
		running
        returns(bool)
	{
        require(!monsters[_id].busy && owner[_id] == msg.sender);
		inSale[_id] = _price;
        emit ForSale(msg.sender, _price);
	}

	function buyMonster(uint256 _id)
		public
		payable
		running
		returns(bool)
    {
		require(inSale[_id] > 0 && msg.value >= inSale[_id]);
        inSale[_id] = 0;
        address owner_ = owner[_id];

        uint256 _fees = calculateFees(msg.value);
        money[owner_] = money[owner_].add(msg.value).sub(_fees);
        money[contractOwner] = money[contractOwner].add(_fees);

        approved[_id] = msg.sender;
        emit Approval(owner_, msg.sender, _id);

        transferFrom(owner_, msg.sender, _id);
        emit Bought(owner_, msg.sender, _id);
	}

	function withdraw () public returns(uint) {
		require(money[msg.sender] > 0 );
		uint256 _amount = money[msg.sender];
		money[msg.sender] = 0;
		msg.sender.transfer(_amount);
        return _amount;
	}

    function lvlUp (
        uint256[] _ids,
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

        for(uint256 i = 0; i<_ids.length; i++) {
            _skillsAvailable = 0;
            require(
                owner[_ids[i]] == msg.sender &&
                monsters[_ids[i]].lvl < 100
            );
            while (
                (monsters[1].lvl/5) <= monsters[1].exp &&
                monsters[1].lvl < 100
            ) {
                monsters[1].lvl++;
                _skillsAvailable += 1;
            }


            require(_atkMod[i] + _defMod[i] + _spdMod[i] <= _skillsAvailable);
            monsters[_ids[i]].atk += _atkMod[i];
            monsters[_ids[i]].def += _defMod[i];
            monsters[_ids[i]].spd += _spdMod[i];
        }
    }

    function test_getContractMoney() public returns(uint256) {

        return this.balance;
    }

}
