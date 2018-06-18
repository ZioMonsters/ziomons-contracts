pragma solidity ^0.4.24;

import "./SafeMath.sol";

contract Owned {
    using SafeMath for uint;

    address owner;
    address newOwner;

    event OwnershipTransfered(
        address indexed _from,
        address indexed _to
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier isOwner {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function nominateNewOwner(address _newOwner) external isOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == newOwner, "You are not the designated god");
        emit OwnershipTransfered(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
