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
    event Results(
				address indexed _attacker,
        address indexed _defender,
        address indexed _winner,
        uint256 _price
    );

	uint8 standardBoxPrice = 2;
	uint8 plusBoxPrice = 5;
	uint8 maxiBoxPrice  = 8;

    constructor() public {
        seed = now;
        for (uint i = 0; i < 5; i++) {
            monsters.push(Monster(1, 1, 1, 1, 1, Rarity.common));
            owner[i] = msg.sender;
        }
    }

	function generateMonster(uint _modPack)
		internal
		returns(Monster)
	{

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

        uint256[6] memory _id;

        for (uint8 i = 0; i < 6; i++) {
            owner[monsters.length] = msg.sender;
            monsters.push(generateMonster(_modifier));
            _id[i] = monsters.length - 1;
            balance[msg.sender] = balance[msg.sender].add(1);
        }

        emit Unboxed(msg.sender, _id);
        return _id;
	}

	function defend(uint256[5] _teamId)
		public
		running
		payable
		returns(bool)
	{
		Monster[5]  _team;
		uint8 i;
		uint256 _lvlTeam = 0;

		for(i = 0; i<5; i++){
			_team[i] = monsters[_teamId[i]];
			_lvlTeam = _lvlTeam.add(monsters[_teamId[i]].lvl);
		}
		onDefence[msg.sender] = Defender(_team, true, msg.value, _lvlTeam/5);
		return true;
	}

	function attack(
		uint256[5] _teamId,
		address _opponent
	)
		public
		running
		returns(bool)
	{
    Monster[5] _team;
		uint8 i;
		uint256 _lvlTeam = 0;

		for(i = 0; i<5; i++){
			_team[i] = monsters[_teamId[i]];
			_lvlTeam = _lvlTeam.add(monsters[_teamId[i]].lvl);
		}

		uint256 _avg = _lvlTeam/5;
		uint8 range = 5;

		require(
			onDefence[_opponent].averageLvl >= _avg-range &&
			onDefence[_opponent].averageLvl <= _avg+range
		);

		uint _winner = startMatch(_team, onDefence[_opponent].deck);
		emit Results (msg.sender,
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

}
