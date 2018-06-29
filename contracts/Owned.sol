pragma solidity ^0.4.24;

import "./SafeMath.sol";


contract Owned {
    using SafeMath for uint256;

    address internal contractOwner;
    address private newOwner;

    event OwnershipTransferred(
        address indexed _from,
        address indexed _to
    );

    constructor() public {
        contractOwner = msg.sender;
    }

    modifier isOwner {
        require(msg.sender == contractOwner);
        _;
    }

    function nominateNewOwner(address _newOwner)
        external
        isOwner
    {
        newOwner = _newOwner;
    }

    function acceptOwnership()
        external
    {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(contractOwner, newOwner);
        contractOwner = newOwner;
    }
}
