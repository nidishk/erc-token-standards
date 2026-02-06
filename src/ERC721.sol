// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ERC721
 * @dev Standard ERC721 NFT implementation
 */
contract ERC721 {
    string public name;
    string public symbol;
    
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
    
    function approve(address to, uint256 tokenId) external {
        address owner = ownerOf[tokenId];
        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "Not authorized");
        getApproved[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
    
    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(from == ownerOf[tokenId], "Not owner");
        require(
            msg.sender == from || 
            msg.sender == getApproved[tokenId] || 
            isApprovedForAll[from][msg.sender],
            "Not authorized"
        );
        
        balanceOf[from]--;
        balanceOf[to]++;
        ownerOf[tokenId] = to;
        delete getApproved[tokenId];
        
        emit Transfer(from, to, tokenId);
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        transferFrom(from, to, tokenId);
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata) external {
        transferFrom(from, to, tokenId);
    }
    
    function _mint(address to, uint256 tokenId) internal {
        require(ownerOf[tokenId] == address(0), "Already minted");
        balanceOf[to]++;
        ownerOf[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }
    
    function _burn(uint256 tokenId) internal {
        address owner = ownerOf[tokenId];
        require(owner != address(0), "Not minted");
        balanceOf[owner]--;
        delete ownerOf[tokenId];
        delete getApproved[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }
}

/**
 * @title ERC721Mintable
 * @dev ERC721 with mint capability
 */
contract ERC721Mintable is ERC721 {
    address public owner;
    uint256 public nextTokenId;
    
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        owner = msg.sender;
    }
    
    function mint(address to) external returns (uint256) {
        require(msg.sender == owner, "Not owner");
        uint256 tokenId = nextTokenId++;
        _mint(to, tokenId);
        return tokenId;
    }
    
    function burn(uint256 tokenId) external {
        require(ownerOf[tokenId] == msg.sender, "Not owner");
        _burn(tokenId);
    }
}
