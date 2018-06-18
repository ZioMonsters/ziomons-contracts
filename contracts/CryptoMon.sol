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

	constructor() public {
		for (uint i = 0; i < 255; i++) {
			monsters.push(Monster(1, 1, 1, 1, 1, common, 1));
		}
	}

	function unbox() public payable running returns(uint256[6]) {
		//TODO
	}

	function defend(uint256[5] _team)
		public
		running
		returns(bool)
	{
		//TODO
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

	function defendBet(uint256[5] _team)
		public
		payable
		running
		returns(bool)
	{
		//TODO
	}

	function attackBet(
		uint256[5] _team,
		address _opponent
	)
		public
		payable
		running
		returns(bool)
	{
		//TODO
	}

	function attackBet(
		uint256[5] _team,
		address _opponent
	)
		public
		payable
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