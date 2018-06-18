pragma solidity ^0.4.24;

contract GameState{
	bool running;

	event RunningStateChanged(bool indexed _state);

	modifier isRunning {
		require(running);
	}

	function changeRunningState(bool _state) public isOwner returns(bool) {
		running = _state;
		emit RunningStateChanged(_state);
		return running;
	}
}