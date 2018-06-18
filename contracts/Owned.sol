pragma solidity ^0.4.24;

import "./SafeMath.sol";

contract Owned {
    using SafeMath for uint;

    address contractOwner;
    address newOwner;

    event OwnershipTransferred(
        address indexed _from,
        address indexed _to
    );

    constructor() public {
        contractOwner = msg.sender;
    }

    modifier isOwner {
        require(msg.sender == contractOwner, "You are not the owner");
        _;
    }

    function nominateNewOwner(address _newOwner) external isOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == newOwner, "You are not the designated god");
        emit OwnershipTransferred(contractOwner, newOwner);
        contractOwner = newOwner;
        newOwner = address(0);
    }
}
