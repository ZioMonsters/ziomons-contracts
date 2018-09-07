pragma solidity ^0.4.24;

/**
  * @title Owned
  * @notice The owner of the contract can change game parameters (See AdminPanel)
  * @notice and the money from fees and unboxes goes to its address.
  * @author Matteo Bonacini
  */
contract Owned {

    // Addresses of the current contract owner and of the nominated one.
    address internal contractOwner;
    address private newOwner;

    /** 
      * @notice Emitted when ownership is transferred.
      * @param _from The old owner
      * @param _to The new owner
      */
    event OwnershipTransferred(
        address indexed _from,
        address indexed _to
    );

    constructor() public {
        // The initial owner is the creator of the contract.
        contractOwner = msg.sender;
    }

    // Used in functions that must be called only from the owner.
    modifier isOwner {
        require(msg.sender == contractOwner);
        _;
    }

    /**
      * @notice Nominates an address to be the new owner. This address then
      * @notice needs to accept ownership by calling the acceptOwnersip
      * @notice function.
      * @dev This is used as a security measure, preventing the current owner
      * @dev from giving ownership to an invalid address.
      * @param _newOwner The address to be nominated.
      * @author Matteo Bonacini
      */
    function nominateNewOwner(address _newOwner) external isOwner {
        // Stores the nominated owner's address.
        newOwner = _newOwner;
    }

    /**
      * @notice Use this function to accept ownership. In order to become the 
      * @notice new owner, you need to have been nominated by the old one.
      * @notice Emits the OwnershipTransferred event if the transfer is succesful.
      * @dev Throws if the address calling the function is not
      * @dev the nominated address.
      * @author Matteo Bonacini
      */
    function acceptOwnership() external {
        // Checks that the address calling the function had been nominated
        // by the current owner.
        require(msg.sender == newOwner);

        // Emits an event to inform everyone.
        emit OwnershipTransferred(contractOwner, newOwner);

        // Stores the new owner's address.
        contractOwner = msg.sender;
    }
}
