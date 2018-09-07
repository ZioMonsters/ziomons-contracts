pragma solidity ^0.4.24;

import "./Interfaces.sol";
import "./Owned.sol";
import "./SafeMath.sol";

/**
  * @title Core
  * @dev In this contract are declared all the storage variables used
  * @dev by the game.
  * @author Emanuele Caruso, Matteo Bonacini
  */
contract Core is Owned, ERC721, ERC165, ERC721Receiver, ERC721Enumerable {
    // Using SafeMath from OpenZeppelin to prevent overflows when dealing
    // with money.
    using SafeMath for uint256;

    //STRUCTS///////////////////////////////////////////////////////
    // Used in the monsters array to store the data for every monster
    struct Monster {
        uint8 atk;
        uint8 def;
        uint8 spd;
        uint8 lvl;
        uint8 rarity;
        uint256 exp;
        bool busy;
    }

    // Used in the waiting array to store data about a person's team
    struct Defender {
        address addr;
        uint32[5] deck;
        uint256 minBet;
        uint256 bet;
    }

    // Used to compute the result of a match
    struct Team {
        uint8 atk;
        uint8 def;
        uint8 spd;
        uint32 id;
    }
    ////////////////////////////////////////////////////////////////

    //VARIABLES/////////////////////////////////////////////////////
    // Main token array, stores data for every monster. The number of monsters
    // is capped at 2**32. Once (and if) that number is reached, the unbox
    // function will be disabled, and the only way to receive a new monster
    // would be to buy it, or receive it with a transfer.
    Monster[] public monsters; //TODO check for overflow whenever a mosnter is created

    // Stores the team and other relevant data for
    // every player who chose to fight in any level range.
    mapping(uint256 => Defender)[100] internal waiting;

    // If a player is waiting, stores its position in the queue ([level, pos])
    // else, it's set to [100, 0]. Used to allow a person to stop waiting for
    // the contract to find an opponent.
    mapping(address => uint256[2]) internal isWaiting;

    // Stores how many players are waiting in each level range.
    // A normal array couldn't be used because of solidity's own limitations
    // (Missing of a .pop method and, most importantly, .length property is not
    // reset after the last element of a dynamically allocated array is deleted).
    uint256[100] internal waitingLength;

    // Stores the sale price for every token. If a token is not in sale,
    // its price is set to 0.
    mapping(uint32 => uint256) public inSale;

    // Stores the owner of every token.
    mapping(uint256 => address) internal owner; //TODO set uint32

    //TODO: auto-withdraw
    mapping(address => uint256) internal money;

    // Stores the number of tokens a person owns. (Needed for the contract
    // to be ERC-721 compliant).
    mapping(address => uint256) internal balances;

    // Stores whether an address is approved to manage all the tokens
    // of another address. (Needed for the contract to be ERC-721 compliant).
    mapping(address => mapping(address => bool)) internal approvedForAll;

    // Stores the approves address for a token. (Needed for the contract
    // to be ERC-721 compliant).
    mapping(uint256 => address) internal approved;

    // Used as seed for the internal RNG.
    uint256 internal seed;
    ////////////////////////////////////////////////////////////////

    //PARAMS///////////////////////////////////////////////////////
    // These are the parameters that can be changed by the onwer. An event is
    // emitted whenever a change occurs. We will try to keep these changes to
    // a minimum, and to let the users know in advance if one is planned.
    uint64[12] public params = [
        2500 szabo,     //standardBoxPrice 1$
        12500 szabo,    //plusBoxPrice 5$
        37500 szabo,    //maxiBoxPrice 15$
        0,              //modifierStandard 1/10000 chance legendary
        700,            //modifierPlus   1/9300  chance legendary
        2000,           //modifierMaxi  1/8000  chance legendary
        5,              //matchmakingRange
        100,            //expUpWinner
        40,             //expUpLoser
        375,            //fees
        1,              //possibleUpgrade
        5               //bonusWinner
    ];
    ////////////////////////////////////////////////////////////////

    //EVENTS////////////////////////////////////////////////////////
    /**
      * @notice Emitted when a player unboxes a pack of monsters.
      * @param _player The address of the player that unboxed the pack.
      * @param _ids An array that contains the ids if the unboxed monsters.
      */
    event Unboxed(
        address indexed _player,
        uint32[6] _ids
    );

    /**
      * @notice Emitted when a player puts a monster up for sale.
      * @param _player The address of whom wants to sell the monster,
      * @param _id The id of the monster put up for sale.
      * @param _price The price of the monster. (Set to 0 if it's not in sale).
      */
    event ForSale(
        address indexed _player,
        uint32 _id,
        uint256 indexed _price
    );

    /**
      * @notice Emitted after the end of a fight.
      * @param _attacker The address of the attacker.
      * @param _defender The address of the defender.
      * @param _team1 Data about the attacker's team. (See dev).
      * @param _team2 Data about the defender's team. (See dev).
      * @param _bonusWinner The parameter bonusWinner at the time of the fight.
      * @param _winnerId Indicates the winner (1=attacker, 2=defender, 3=draw).
      * @param _moneyWon The amount of money won by the winner.
      * @dev To allow users to re-play their previous fights, the event
      * @dev contains data about the team of each user. Due to solidity's
      * @dev own limitations, the format is not very straightforward.
      * @dev _team1 and _team2 contain atk, def, spd and id of the monsters
      * @dev involved in the fight. Data is stored as follows:
      * @dev [atk(*5), def(*5), spd(*5), id(*5)].
      */
    event Results(
        address indexed _attacker,
        address indexed _defender,
        uint32[20] _team1,
        uint32[20] _team2,
        uint8 _bonusWinner,
        uint256 indexed _winnerId,
        uint256 _moneyWon
    );

    /**
      * @notice Emitted when a parameter is changed
      * @param _parameter The id of the parameter changed.
      * @param _oldValue The old value of the parameter.
      * @param _newValue The new value of the parameter.
      */
    event Changed(
        uint8 indexed _parameter,
        uint256 _oldValue,
        uint256 _newValue
    );

    /**
      * @notice Emitted when a player upgrades a monster's stats.
      * @param _id The id of the monster.
      * @param _atkMod The increase of the attack.
      * @param _defMod The increase of the defence.
      * @param _spdMod The increase of the speed.
      */
    event Upgraded(
        uint32 _id,
        uint8 _atkMod,
        uint8 _defMod,
        uint8 _spdMod
    );
    ///////////////////////////////////////////////////////////////

    //MODIFIERS////////////////////////////////////////////////////
    // Used in some ERC-721 functions to check wheter an address is authorized
    // to perform actions on a token.
    // Throws if _sender is not the owner or an approved address for _id.
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
