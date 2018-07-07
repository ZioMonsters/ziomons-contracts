pragma solidity ^0.4.24;

import "./ERCCore.sol";

/**
  * @title AdminPanel
  * @notice Contains functions that can be called only by the owner.
  * @author Emanuele Caruso
  */
contract AdminPanel is ERCCore {

    function createCustomMonster( //TODO REMOVE, just for testing
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
    /**
      * @notice Changes contract parameters. Can only be called by the owner.
      * @notice Checks on the new value MUST be performed BY THE CALLER.
      * @param _parameter The id of the parameter to be changed.
      * @param _newValue The new value of the parameter.
      * @author Emanuele Caruso
      */
    function changeParameter(uint8 _parameter, uint16 _newValue)
        external
        isOwner
    {
        // Checks that the parameter ID is valid. This is the only check this
        // functions performs.
        require(_newValue >= 0 && _parameter <= 11);

        // Tells everyone about the change.
        emit Changed(_parameter, params[_parameter], _newValue);

        // Stores the new value.
        params[_parameter] = _newValue;
    }
}
