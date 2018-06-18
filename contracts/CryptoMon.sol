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
		for (uint i = 0; i < 255; i++) {
			monsters.push(Monster(1, 1, 1, 1, 1, common, 1));
		}
	}

	function unbox() public payable running returns(uint256[6]) {
		//TODO
	}

	uint256 seed = now;

	function random ()
		internal
		pure
		returns(uint256)
	{
		seed = (4832897258932085 * seed + 34732894208) % 4325352;
		return seed;
	}

	function genMonster(uint8 _modPack)
		internal
		pure
		returns(Monster)
	{

		uint8 _modRarity = ( random()%(100-_modPack) == 42)? 6: (random()%(1000-(_modPack*5)) == 42)? 8: (random()%(10000-(_modPack*10)) == 42)? 9:5;
		return Monster(
				random()%4 + _modRarity,
				random()%4 + _modRarity,
				random()%4 + _modRarity,
				5,
				0,
				(_modRarity == 5)? Rarity.common:(_modRarity == 6)? Rarity.rare:(_modRarity == 8)? Rarity.epic:Rarity.legendary,
				0
			);
	}

	function unbox()
		public
		payable
		running
		returns(uint256[6])
	{
		require(msg.value >= standardBoxPrice);
		if (msg.value >= maxiBoxPrice ) {
			for (uint8 i = 0; i<6; i++){
				owner[monsters.length] = msg.sender;
				Monster.push(genMonster(20));
				balance[msg.sender] = balance[msg.sender].add(1);
			}
		} else if (msg.value >= plusBoxPrice){
			for (uint8 i = 0; i<6; i++){
				owner[monsters.length] = msg.sender;
				Monster.push(genMonster(10));
				balance[msg.sender] = balance[msg.sender].add(1);
			}
		} else {
			for (uint8 i = 0; i<6; i++){
				owner[monsters.length] = msg.sender;
				Monster.push(genMonster(0));
				balance[msg.sender] = balance[msg.sender].add(1);
			}
		}

	}

	function defend(uint256[5] _team)
		public
		running
		returns(bool)
	{
		/* TODO */
	}

	function attack(
		uint256[5] _team,
		address _opponent
	)
		public
		running
		returns(bool)
	{
		//TODO
	}

	function sellMonster(
		uint256 _id,
		uint256 price
	)
		public
		running
		returns(bool)
	{
		//TODO
	}

	function buyMonster(uint256 _id)
		public
		payable
		running
		returns(bool) {
		//TODO
	}

}
