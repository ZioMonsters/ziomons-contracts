pragma solidity ^0.4.24;

import "./ERCCore.sol";
import "./SafeMath.sol";

contract CryptoMon is ERCCore {

using SafeMath for uint8;

	event Unboxed(
		address indexed _player,
		uint256[6] _monsters
    );
    event ForSale(
        address indexed _player,
        uint256 indexed _price
    );
    event Bought(
        address indexed _from,
        address indexed _to,
        uint256 _id
    );
    event Defending(
        address indexed _defender,
        uint256 indexed _bet,
        uint256 indexed _level
    );
    event Results(
        address indexed _attacker,
        address indexed _defender,
        address indexed _winner,
        uint256 _price
    );

	uint8 standardBoxPrice = 2;
	uint8 plusBoxPrice = 5;
	uint8 maxiBoxPrice  = 8;

    uint256 matchmakingRange = 5;

    constructor() public {
        seed = now;
        for (uint i = 0; i < 5; i++) {
            monsters.push(Monster(1, 1, 1, 1, 1, Rarity.common));
            owner[i] = msg.sender;
        }
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
            monsters.push(generateMonster(_modifier));
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
        //TODO Fix matchmaking level
        uint256 _level;
        for (uint8 i = 0; i < 5; i++) {
            require(owner[_ids[i]] == msg.sender);
            _level += monsters[_ids[i]].lvl;
        }
        _level = _level / 5;

		onDefence[msg.sender] = Defender(_ids, msg.value, uint8(_level), true);
        money[contractOwner] += msg.value;

        emit Defending(msg.sender, msg.value, _level);
		return true;
	}

	function attack(
		uint256[5] _ids,
		address _opponent
	)
		public
		running
		returns(bool)
	{
        //TODO fix matchmaking level
        uint256 _level;
        for (uint8 i = 0; i < 5; i++) {
            _level += monsters[_ids[i]].lvl;
        }
        _level = _level / 5;

		require(
			onDefence[_opponent].level >= _level - matchmakingRange &&
			onDefence[_opponent].level <= _level + matchmakingRange &&
            onDefence[_opponent].bet <= msg.value
		);

        money[contractOwner] += msg.value;

		uint _winner = startMatch(_ids, onDefence[_opponent].deck);
		emit Results (
            msg.sender,
			_opponent,
			(_winner == 1)? msg.sender:(_winner == 2)? _opponent: address(0),
			msg.value.add(onDefence[_opponent].bet)
		);
		return true;
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

    function generateMonster(uint _modPack)
        private
        returns(Monster)
    {
        //TODO better format
        uint256 _modRarity = ( random()%(100-_modPack) == 42)? 6: (random()%(1000-(_modPack*5)) == 42)? 8: (random()%(10000-(_modPack*10)) == 42)? 9:5;
        return Monster(
            uint8(	random()%4 + _modRarity),
            uint8(random()%4 + _modRarity),
            uint8(random()%4 + _modRarity),
            5,
            0,
            (_modRarity == 5)? Rarity.common:(_modRarity == 6)? Rarity.rare:(_modRarity == 8)? Rarity.epic:Rarity.legendary
        );
    }

		

}
