pragma solidity ^0.4.24;

import "./ERCCore.sol";

contract AdminPanel is ERCCore {

    function changeParameter (uint8 _parameter ,uint256 _newValue)
        public
        isOwner
        returns (uint256)
    {

        require(_newValue>=0);

        if(_parameter == 0) {                                       //standardBoxPrice
            standardBoxPrice = _newValue;
            emit Changed(_parameter, _newValue);
            return standardBoxPrice;
        } else if (_parameter == 1) {                               //plusBoxPrice
            plusBoxPrice = _newValue;
            emit Changed(_parameter, _newValue);
            return plusBoxPrice;
        } else if (_parameter == 2) {                               //maxiBoxPrice
            maxiBoxPrice = _newValue;
            emit Changed(_parameter, _newValue);
            return maxiBoxPrice;
        } else if (_parameter == 3) {                               //modifierStandard
            require(_newValue < 1000);
            modifierStandard = _newValue;
            emit Changed(_parameter, _newValue);
            return modifierStandard;
        } else if (_parameter == 4) {
            require(_newValue < 1000);                              //modifierPlus
            modifierPlus = _newValue;
            emit Changed(_parameter, _newValue);
            return modifierPlus;
        } else if (_parameter == 5) {
            require(_newValue < 1000);                              //modifierMaxi
            modifierMaxi = _newValue;
            emit Changed(_parameter, _newValue);
            return modifierMaxi;
        } else if (_parameter == 6) {
            require(_newValue < 100);                         //matchmakingRange
            matchmakingRange = _newValue;
            emit Changed(_parameter, _newValue);
            return matchmakingRange;
        } else if (_parameter == 7) {
            possibleUpgrade = _newValue;
            emit Changed(_parameter, _newValue);
            return _newValue;
        }
        else if (_parameter == 8) {
            require(_newValue <= 1000);
            fees = _newValue;
            emit Changed(_parameter, _newValue);
            return _newValue;
        } else {
            return 42;
        }
    }


}
