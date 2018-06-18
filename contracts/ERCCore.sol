pragma solidity ^0.4.24;

import "./Core.sol";

contract ERCCore is Core {
    using SafeMath for uint;

    function balanceOf(address _owner)
        external
        view
        returns(uint256)
    {
        require(_owner != address(0));
        return balance[_owner];
    }

    function ownerOf(uint256 _tokenId)
    external
    view
    returns(address)
    {
        require(owner[_tokenId] != address(0));
        return owner[_tokenId];
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes data
    ) 
        public
        payable
        isAuthorized
    {
        transferFrom(_from, _to, _tokenId);
        if (isContract(_to)) {
            bytes4 _retval = ERC721Receiver(_to).onERC721Received(
                _from, _tokenId, _data
            );
            require(_retval == ERC721_RECEIVED);
        }
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
        payable
        isAuthorized(msg.sender, _tokenId)
    {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
        payable
        isAuthorized(msg.sender, _tokenId)
    {
        require(
            _from == owner[_tokenId] &&
            _to != address(0) &&
            _tokenId < monsters.length
        );
        owner[_tokenId] = _to;
        approve(address(0), _tokenId);
        emit Transfer(_from, _to, _tokenId);
    }

    function approve(
        address _approved,
        uint256 _tokenId
    )
        public
        payable
        isAuthorized(msg.sender, _tokenId)
    {
        approved[_tokenId] = _approved;
        Approval(msg.sender, _approved, _tokenId);
    }

    function setApprovalForAll(
        address _operator,
        bool _approved
    ) external {
        approvedForAll[msg.sender][_operator] = _approved
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId)
        external
        view
        returns(address)
    {
        require(_tokenId < monsters.length);
        return approved[_tokenId];
    }

    function isApprovedForAll(
        address _owner,
        address _operator
    )
        external
        view
        returns(bool)
    {
        return approvedForAll[_owner][_operator];
    }
    
    function supportsInterface(bytes4 interfaceID)
        external
        view
        returns (bool)
    {
        bytes4 InterfaceSignature_ERC165 =
            bytes4(keccak256('supportsInterface(bytes4)'));                                                                                                       [0/373]

        bytes4 InterfaceSignature_ERC721 =
            bytes4(keccak256('balanceOf(address)')) ^
            bytes4(keccak256('ownerOf(uint256)')) ^
            bytes4(keccak256('approve(address,uint256)')) ^
            bytes4(keccak256('getApproved(uint256)')) ^
            bytes4(keccak256('setApprovalForAll(address,bool)')) ^
            bytes4(keccak256('isApprovedForAll(address,address)')) ^
            bytes4(keccak256('transferFrom(address,address,uint256)')) ^
            bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
            bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'));

        return(
            interfaceID == InterfaceSignature_ERC165 ||
            interfaceID == InterfaceSignature_ERC721
        );        
    }
}