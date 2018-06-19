pragma solidity ^0.4.24;

import "./Mortal.sol";

contract State is Mortal{
	bool public isRunning = true;

	event RunningStateChanged(bool indexed _state);

	modifier running {
		require(isRunning);
		_;
	}

	function changeRunningState(bool _state) public isOwner returns(bool) {
		isRunning = _state;
		emit RunningStateChanged(_state);
		return isRunning;
	}
}
