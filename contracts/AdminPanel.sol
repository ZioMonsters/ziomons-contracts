pragma solidity ^0.4.24;

import "./ERCCore.sol";

contract AdminPanel is ERCCore {

    function changeParameter (uint8 _parameter ,uint16 _newValue)
        public
        isOwner
        returns (uint256)
    {

        require(_newValue>=0 && _parameter<=11);
        emit Changed(_parameter, params[_parameter], _newValue);
        params[_parameter] = _newValue;
    }
}






/* if(_parameter == 0) {                                       //standardBoxPrice
    emit Changed(_parameter, standardBoxPrice,_newValue);
    standardBoxPrice = _newValue;
    return standardBoxPrice;
} else if (_parameter == 1) {                               //plusBoxPrice
    emit Changed(_parameter, plusBoxPrice,_newValue);
    plusBoxPrice = _newValue;
    return plusBoxPrice;
} else if (_parameter == 2) {                               //maxiBoxPrice
    emit Changed(_parameter, maxiBoxPrice,_newValue);
    maxiBoxPrice = _newValue;
    return maxiBoxPrice;
} else if (_parameter == 3) {                               //modifierStandard
    require(_newValue < 1000);
    emit Changed(_parameter, modifierStandard,_newValue);
    modifierStandard = _newValue;
    return modifierStandard;
} else if (_parameter == 4) {
    require(_newValue < 1000);                              //modifierPlus
    emit Changed(_parameter, modifierPlus,_newValue);
    modifierPlus = _newValue;
    return modifierPlus;
} else if (_parameter == 5) {
    require(_newValue < 1000);                              //modifierMaxi
    emit Changed(_parameter, modifierMaxi,_newValue);
    modifierMaxi = _newValue;
    return modifierMaxi;
} else if (_parameter == 6) {
    require(_newValue < 100);                         //matchmakingRange
    emit Changed(_parameter, matchmakingRange,_newValue);
    matchmakingRange = _newValue;
    return matchmakingRange;
} else if (_parameter == 7) {
    emit Changed(_parameter, possibleUpgrade,_newValue);
    possibleUpgrade = uint8(_newValue);
    return _newValue;
}
else if (_parameter == 8) {
    require(_newValue <= 1000);
    emit Changed(_parameter, fees,_newValue);
    fees = _newValue;
    return _newValue;
} else if(_parameter == 9) {
    emit Changed(_parameter, bonusWinner, _newValue);
    bonusWinner = uint8(_newValue);
    return _newValue;
} else {
    return 42;
} */
