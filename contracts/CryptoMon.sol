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
            uint8 _rare;

        if (_tmp == 1) {
            _modRarityMin = 17;
            _modRarityMax = 21;
            _rare = 3;
        } else if (_tmp < 11) {
            _modRarityMin = 14;
            _modRarityMax = 17;
            _rare = 2;
		} else if (_tmp < 200) {
            _modRarityMin = 11;
            _modRarityMax = 14;
            _rare = 1;
		} else {
    		_modRarityMin = 8;
            _modRarityMax = 11;
    		_rare = 0;
        }

      monsters.push(
          Monster(
              uint8(randInt(_modRarityMin, _modRarityMax)),
              uint8(randInt(_modRarityMin, _modRarityMax)),
              uint8(randInt(_modRarityMin, _modRarityMax)),
              1,
              0,
	          _rare
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

	function defend(uint256[5] _ids, uint256 _minBet)
		public
		payable
		running
        returns(bool)
    {
        require(_minBet <= msg.value);
        require(notDuplicate(_ids));
        uint256 _level;
        for (uint8 i = 0; i < 5; i++) {
            require(owner[_ids[i]] == msg.sender);
            if (monsters[_ids[i]].lvl > _level)
                _level = monsters[_ids[i]].lvl;
        }

		onDefence[msg.sender] = Defender(
            _ids,
            _minBet,
             msg.value,
             uint8(_level),
             true
        );
        moneyPending = moneyPending.add(msg.value);

        emit Ready(msg.sender, _minBet, msg.value, _level, address(0));
		return true;
	}

	function attack(
		uint256[5] _ids,
		address _opponent,
        uint256 _minBet
	)
		public
		payable
		running
	{
        require(_minBet <= msg.value);
        require(notDuplicate(_ids));
        uint256 _level;
        for (uint8 i = 0; i < 5; i++) {
            require(owner[_ids[i]] == msg.sender);
            if (monsters[_ids[i]].lvl > _level)
                _level = monsters[_ids[i]].lvl;
        }
		require(
            (
                matchmakingRange > _level ||
                onDefence[_opponent].level >= _level - matchmakingRange
            ) &&
			//onDefence[_opponent].level <= _level + matchmakingRange && //cazzi tuoi
            onDefence[_opponent].bet >= _minBet &&
            onDefence[_opponent].minBet <= msg.value &&
            onDefence[_opponent].defending == true
		);

        moneyPending = moneyPending.add(msg.value);
        onDefence[_opponent].defending = false;
		emit Ready(msg.sender, _minBet, msg.value, _level , _opponent);
		uint256 _winnerId = startMatch(_ids, onDefence[_opponent].deck);
        address _winner;
        address _loser;
        uint256 _betWinner;
        uint256 _betLoser;
        if (_winnerId == 1) {
            _winner = msg.sender;
            _betWinner = msg.value;
            _betLoser = onDefence[_opponent].bet;
        } else if (_winnerId == 2) {
            _winner = _opponent;
            _betLoser = msg.value;
            _betWinner = onDefence[_opponent].bet;
        } else {
            _winner = address(0);
        }

        moneyPending = moneyPending.sub(msg.value).sub(onDefence[_opponent].bet); //TODO fee

        uint256 _moneyWon;
        if (_winner == address(0)) {
            money[_opponent] = money[_opponent].add(onDefence[_opponent].bet);
            money[msg.sender] = money[msg.sender].add(msg.value);
            emit Results (
                msg.sender,
                _opponent,
                0,
                0
            );
            return;
        } else if (onDefence[_opponent].bet > msg.value) {
            _moneyWon = msg.value;
        } else {
            _moneyWon = onDefence[_opponent].bet;
        }
        uint256 _fees = calculateFees(_moneyWon.add(_betWinner));
        money[_winner] = money[_winner].add(_moneyWon).add(_betWinner).sub(_fees);
        money[_loser] = money[_loser].add(_betLoser).sub(_moneyWon);
        money[contractOwner] = money[contractOwner].add(_fees); //TODO CHECK if working

		emit Results (
             msg.sender,
			_opponent,
			_winnerId,
            _moneyWon
		);
	}

	function sellMonster(
		uint256 _id,
		uint256 _price
	)
		public
		running
        isAuthorized(msg.sender, _id)
        returns(bool)
	{
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
        money[owner_] = money[owner_].sub(_fees).add(msg.value);
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
        public
    {
        require(
            _ids.length == _atkMod.length &&
            _atkMod.length == _defMod.length &&
            _defMod.length == _spdMod.length
        );
        for(uint256 i = 0; i<_ids.length; i++) {
            require(
                owner[_ids[i]] == msg.sender &&
                monsters[_ids[i]].exp >= ((monsters[_ids[i]].lvl**3)/5) &&  /* TODO parametrizzare */
                monsters[_ids[i]].lvl < 100 &&
                _atkMod[i] + _defMod[i] + _spdMod[i] == possibleUpgrade
            ); /* TODO definire ogni quanto aumenta */

            monsters[_ids[i]].lvl++;
            /*  TODO CAP require(monsters[_ids[i]].atk + _atkMod[i] < monsters[_ids[i]].lvl*2 + monsters[_ids[i]].atkI );  */
            monsters[_ids[i]].atk += _atkMod[i];
            /* TODO CAP def*/
            monsters[_ids[i]].def += _defMod[i];
            /* TODO CAP spd */
            monsters[_ids[i]].spd += _spdMod[i];
        }
    }

    function test_getContractMoney() public returns(uint256) {

        return this.balance;
    }

}
