// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

    interface IERC165 {
        function supportsInterface(bytes4 interfaceId) external view returns(bool);
    }

    interface IERC721 is IERC165 {
        function balanceOf(address owner) external view returns(uint256 balance);
        function ownerOf(uint tokenId) external view returns(address owner);
        
        function safeTransferFrom(address from, address to, uint256 tokenid, bytes calldata data) external;
        function safeTransferFrom(address from, address to, uint256 tokenid ) external;
        function transferFrom(address from, address to, uint256 tokenId) external;
        
        function approve(address to, uint256 tokenId) external;
        function getApproved(uint256 tokenId) external view returns(address operator);
        function setApprovalForAll(address operator, bool _approved) external;
        function isApprovedForAll(address owner, address operator) external view returns(bool);
    }

    interface IERC721Receiver {
        function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns(bytes4);
    }

    abstract contract ERC721 is IERC721{
        event Transfer(address indexed from, address indexed to, uint256 indexed id);
        event Approval(address indexed owner, address indexed spender, uint256 indexed id);
        event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

        mapping(uint256 => address) internal _ownerOf;
        mapping(address => uint256) internal _balanceOf;
        mapping(uint256 => address) internal _approvals;
        mapping(address => mapping(address => bool)) public isApprovedForAll;

        function supportsInterface(bytes4 interfaceId) external pure returns(bool) {
            return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC165).interfaceId;
        }

        function balanceOf(address owner) external view returns(uint256 balance){
            require(owner != address(0), "owner = zero address");
            return _balanceOf[owner];
        }
        function ownerOf(uint tokenId) external view returns(address owner){
            return _ownerOf[tokenId];
            require(owner != address(0), "token doesnt exist");
        }
        
     function transferFrom(address from, address to, uint256 id) public {
        require(from == _ownerOf[id], "from != owner");
        require(to != address(0), "transfer to zero address");

        require(_isApprovedOrOwner(from, msg.sender, id), "not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;

        delete _approvals[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint256 id) external {
        transferFrom(from, to, id);

        require(
            to.code.length == 0
                || IERC721Receiver(to).onERC721Received(msg.sender, from, id, "")
                    == IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) external {
        transferFrom(from, to, id);

        require(
            to.code.length == 0
                || IERC721Receiver(to).onERC721Received(msg.sender, from, id, data)
                    == IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }
        function approve(address to, uint256 tokenId) external { 
            address owner = _ownerOf[tokenId];
            require( msg.sender == owner || isApprovedForAll[owner][msg.sender], "not authorized");
            _approvals[tokenId] = to;
            emit Approval(owner, to, tokenId);
        }
        function getApproved(uint256 tokenId) external view returns(address operator) { 
            require(_ownerOf[tokenId] != address(0), "token doesnt exist");
            return _approvals[tokenId];
        }

        function setApprovalForAll(address operator, bool _approved) external { 
            isApprovedForAll[msg.sender][operator] = _approved;
            emit ApprovalForAll(msg.sender, operator, _approved);
        }

        function _isApprovedOrOwner(address owner, address spender, uint256 id) internal view returns(bool){
            return (spender == owner || isApprovedForAll[owner][spender] || spender == _approvals[id]);
        }

        function _mint(address to, uint256 id) internal {
            require(to != address(0), "mint to zero address");
            require(_ownerOf[id] == address(0), "already minted");

            _balanceOf[to]++;
            _ownerOf[id] = to;

            emit Transfer(address(0), to, id);
        }

        function _burn(uint256 id) internal {
            address owner = _ownerOf[id];
            require(owner != address(0), "not minted");

            _balanceOf[owner] -= 1;

            delete _ownerOf[id];
            delete _approvals[id];

            emit Transfer(owner, address(0), id);
        }
    }

    contract MyNFT is ERC721 {
        function mint(address to, uint256 id) external {
            _mint(to, id);
        }

        function burn(uint256 id) external {
            require(msg.sender == _ownerOf[id], "not owner");
            _burn(id);
        }
    }