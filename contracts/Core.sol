pragma solidity ^0.4.24;

import "./Interfaces.sol";
import "./State.sol";

contract Core is State, ERC721, ERC165, ERC721Receiver, ERC721Enumerable {
	using SafeMath for uint8;

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
        uint8 level;
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

    //PARAMS//
    uint16[12] params = [2, 5, 8, 0, 100, 200, 5, 100, 40, 375, 1, 1];
    /* uint256 standardBoxPrice = 2;
    uint256 plusBoxPrice = 5;
    uint256 maxiBoxPrice  = 8;
    uint256 modifierStandard = 0;
    uint256 modifierPlus = 100;
    uint256 modifierMaxi = 200;
    uint256 matchmakingRange = 5;
    uint256 expUpWinner = 100;
    uint256 expUpLoser = 40;
    uint256 fees = 375;
    uint8 possibleUpgrade = 1;
    uint8 bonusWinner = 1; */

    mapping(uint256 => address) owner;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => bool)) approvedForAll;
    mapping(uint256 => address) approved;
    mapping(address => uint256) public money;
    mapping(uint256 => uint256) public inSale;
    ////////////////////////////////////////////////////////////////

    //EVENTS////////////////////////////////////////////////////////
    event Unboxed(
        address indexed _player,
        uint256[6] _monsters
    );
    event ForSale(
        address indexed _player,
        uint32 _id,
        uint256 indexed _price
    );
    event Results(
        address indexed _attacker,
        address indexed _defender,
        uint8 bonusWinner,
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
