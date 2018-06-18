pragma solidity ^0.4.24;

import "./ERCCore.sol";

contract CryptoMon is ERCCore {

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
        address indexed _defender,
        address indexed _attacker,
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

	function genMonster(uint _modPack)
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
		require(msg.value >= standardBoxPrice);
		uint8 i = 0;
		if (msg.value >= maxiBoxPrice ) {
			for (i = 0; i<6; i++) {
				owner[monsters.length] = msg.sender;
				monsters.push(genMonster(20));
				balance[msg.sender] = balance[msg.sender].add(1);
			}
		} else if (msg.value >= plusBoxPrice) {
			for (i = 0; i<6; i++){
				owner[monsters.length] = msg.sender;
				monsters.push(genMonster(10));
				balance[msg.sender] = balance[msg.sender].add(1);
			}
		} else {
			for (i = 0; i<6; i++) {
            owner[monsters.length] = msg.sender;
                monsters.push(genMonster(0));
            balance[msg.sender] = balance[msg.sender].add(1);
            }
		}

	}

	function defend(uint256[5] _team)
		public
		running
		returns(bool)
	{
		onDefence[msg.sender] = Defender(_team, true);
		return true;
	}

	function attack(
		uint256[5] _team,
		address _opponent
	)
		public
		running
		returns(bool)
	{
		startMatch(_team, onDefence[_opponent].deck);
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
