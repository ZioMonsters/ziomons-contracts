pragma solidity ^0.4.24;

import "./Interfaces.sol";
import "./Owned.sol";

contract Core is Owned, ERC721, ERC165, ERC721Receiver, ERC721Enumerable {

    //STRUCTS///////////////////////////////////////////////////////
	struct Monster {
		uint8 atk;
		uint8 def;
		uint8 spd;
		uint8 lvl;
        uint8 rarity;
        uint256 exp;
        bool busy;
	}

	struct Defender {
        address addr;
		uint32[5] deck;
        uint256 minBet;
        uint256 bet;
	}

    struct Team {
        uint8 atk;
        uint8 def;
        uint8 spd;
        uint32 id;
    }
    ////////////////////////////////////////////////////////////////

    //VARIABLES/////////////////////////////////////////////////////
	Monster[] public monsters;
    uint256 seed;
    uint256 moneyPending;
    mapping (uint256 => Defender)[100] public waiting; //TODO remove public
    uint256[100] public waitingLength; //todo remove public
    mapping (address => uint256[2]) isWaiting;

    //PARAMS//
    uint16[12] params = [
        2,    //standardBoxPrice
        5,    //plusBoxPrice
        8,    //maxiBoxPrice
        0,    //modifierStandard
        100,  //modifierPlus
        200,  //modifierMaxi
        5,    //matchmakingRange
        100,  //expUpWinner
        40,   //expUpLoser
        375,  //fees
        1,    //possibleUpgrade
        1     //bonusWinner
    ];

    mapping(uint256 => address) owner;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => bool)) approvedForAll;
    mapping(uint256 => address) approved;
    mapping(address => uint256) public money;
    mapping(uint32 => uint256) public inSale;
    ////////////////////////////////////////////////////////////////

    //EVENTS////////////////////////////////////////////////////////
    event ForSale(
        address indexed _player,
        uint32 _id,
        uint256 indexed _price
    );
    event Results(
        address indexed _attacker,
        address indexed _defender,
        uint32[40] _data,
        uint8 _bonusWinner,
        uint256 indexed _winnerId,
        uint256 _moneyWon
    );
    event Changed(
        uint8 indexed _parameter,
        uint256 _oldValue,
        uint256 _newValue
    );
    ///////////////////////////////////////////////////////////////

    //MODIFIERS////////////////////////////////////////////////////
	modifier isAuthorized(address _sender, uint256 _id) {
		require(
			owner[_id] == _sender ||
			approved[_id] == _sender ||
			approvedForAll[owner[_id]][_sender]
		);
		_;
	}
    ////////////////////////////////////////////////////////////////
}
