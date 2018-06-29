pragma solidity ^0.4.24;

import "./ERCCore.sol";


contract AdminPanel is ERCCore {

    function createCustomMonster( //TODO Add check whenever a mosnter is created
        uint8 _atk,
        uint8 _def,
        uint8 _spd,
        uint8 _lvl,
        uint8 _rarity,
        uint256 _exp
    )
        external
        isOwner
        returns(uint32)
    {
        monsters.push(
            Monster(
                _atk,
                _def,
                _spd,
                _lvl,
                _rarity,
                _exp,
                false
            )
        );
        owner[monsters.length] = msg.sender;
        emit Transfer(address(0), msg.sender, monsters.length);
        return(uint32(monsters.length));
    }

    function changeParameter (uint8 _parameter, uint16 _newValue)
        external
        isOwner
        returns (uint256)
    {

        require(_newValue >= 0 && _parameter <= 11);
        emit Changed(_parameter, params[_parameter], _newValue);
        params[_parameter] = _newValue;
    }
}
