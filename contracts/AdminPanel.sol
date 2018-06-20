pragma solidity ^0.4.24;

import "./ERCCore.sol";

contract AdminPanel is ERCCore {

    function changeStandardBoxPrice (uint256 _newValue)
        public
        isOwner
        returns (uint256)
    {
        require(_newValue>=0);
        standardBoxPrice = _newValue;
        return standardBoxPrice;
    }

    function changePlusBoxPrice (uint256 _newValue)
        public
        isOwner
        returns (uint256)
    {
        require(_newValue>=0);
        plusBoxPrice = _newValue;
        return plusBoxPrice;
    }

    function changeMaxiBoxPrice (uint256 _newValue)
        public
        isOwner
        returns (uint256)
    {
        require(_newValue>=0);
        maxiBoxPrice = _newValue;
        return maxiBoxPrice;
    }

    function changeModifierStandard (uint256 _newValue)
        public
        isOwner
        returns (uint256)
    {
        require(_newValue>=0);
        modifierStandard = _newValue;
        return modifierStandard;
    }

    function changeModifierPlus (uint256 _newValue)
        public
        isOwner
        returns (uint256)
    {
        require(_newValue>=0);
        modifierPlus = _newValue;
        return modifierPlus;
    }

    function changeModifierMaxi (uint256 _newValue)
        public
        isOwner
        returns (uint256)
    {
        require(_newValue>=0);
        modifierMaxi = _newValue;
        return modifierMaxi;
    }

    function changeMatchMakingRange (uint256 _newValue)
        public
        isOwner
        returns (uint256)
    {
        require(_newValue>=0);
        matchmakingRange = _newValue;
        return matchmakingRange;
    }

}
