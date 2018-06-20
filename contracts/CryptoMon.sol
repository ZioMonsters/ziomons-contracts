pragma solidity ^0.4.24;

import "./ERCCore.sol";
import "./SafeMath.sol";

contract CryptoMon is ERCCore {

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
        uint8 _modifier;
        if (msg.value >= maxiBoxPrice)
            _modifier = 20;
        else if (msg.value >= plusBoxPrice)
            _modifier = 10;
        else if (msg.value >= standardBoxPrice)
            _modifier = 0;
        else
            revert();

        uint256[6] memory _ids;

        for (uint8 i = 0; i < 6; i++) {
            owner[monsters.length] = msg.sender;
            //FIXME random numbers
            uint256 _tmp = randInt(0, 10000);
            uint256 _modRarityMin;
            uint256 _modRarityMax;
            uint8 _rare;

            if (_tmp == 0) {
							_modRarityMin = 17;
							_modRarityMax = 21;
							_rare = 3;
						}
            else if (_tmp < 11) {
							_modRarityMin = 14;
							_modRarityMax = 17;
							_rare = 2;
						}
            else if (_tmp < 2000) {
							_modRarityMin = 11;
							_modRarityMax = 14;
							_rare = 1;
						}
            else {
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
        money[contractOwner] += msg.value;

        emit Unboxed(msg.sender, _ids);
        return _ids;
	}

	function defend(uint256[5] _ids)
		public
		payable
		running
		returns(bool)
    {
        require(notDuplicate(_ids));
        uint256 _level;
        for (uint8 i = 0; i < 5; i++) {
            require(owner[_ids[i]] == msg.sender);
            if (monsters[_ids[i]].lvl > _level)
                _level = monsters[_ids[i]].lvl;
        }

		onDefence[msg.sender] = Defender(_ids, msg.value, uint8(_level), true);
        money[contractOwner] += msg.value;

        emit Ready(msg.sender, msg.value, _level, address(0));
		return true;
	}

	function attack(
		uint256[5] _ids,
		address _opponent
	)
		public
		payable
		running
		returns(uint)
	{
        require(_opponent != msg.sender);
        require(notDuplicate(_ids));
        uint256 _level;
        for (uint8 i = 0; i < 5; i++) {
            require(owner[_ids[i]] == msg.sender);
            if (monsters[_ids[i]].lvl > _level)
                _level = monsters[_ids[i]].lvl;
        }
        //FIXME FIX REQUIRE
		require(
            (
                matchmakingRange > _level ||
                onDefence[_opponent].level >= _level - matchmakingRange
            ) && //FIXME Overfloqw
			//onDefence[_opponent].level <= _level + matchmakingRange && //cazzi tuoi
            //onDefence[_opponent].bet <= msg.value && //TODO money rewards system
            onDefence[_opponent].defending == true
		);

        money[contractOwner] += msg.value;
        onDefence[_opponent].defending = false;
		emit Ready(msg.sender, msg.value, _level , _opponent);
		uint _winner = startMatch(_ids, onDefence[_opponent].deck);

		emit Results (
             msg.sender,
			_opponent,
			(_winner == 1)? msg.sender:(_winner == 2)? _opponent: address(0),
			msg.value.add(onDefence[_opponent].bet)
		);
		return _winner;
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
        approve(msg.sender, _id);
        address owner_ = owner[_id];
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
}
