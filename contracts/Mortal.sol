pragma solidity ^0.4.24;

import "./Owned.sol";

contract Mortal is Owned {
    function kill() external isOwner {
        selfdestruct(contractOwner);
    }
}
