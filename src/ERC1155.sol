// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ERC1155
 * @dev Multi-token standard implementation
 */
contract ERC1155 {
    mapping(uint256 => mapping(address => uint256)) public balanceOf;
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);
    
    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata) external {
        require(msg.sender == from || isApprovedForAll[from][msg.sender], "Not authorized");
        balanceOf[id][from] -= amount;
        balanceOf[id][to] += amount;
        emit TransferSingle(msg.sender, from, to, id, amount);
    }
    
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata
    ) external {
        require(msg.sender == from || isApprovedForAll[from][msg.sender], "Not authorized");
        require(ids.length == amounts.length, "Length mismatch");
        
        for (uint256 i = 0; i < ids.length; i++) {
            balanceOf[ids[i]][from] -= amounts[i];
            balanceOf[ids[i]][to] += amounts[i];
        }
        
        emit TransferBatch(msg.sender, from, to, ids, amounts);
    }
    
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory) {
        require(accounts.length == ids.length, "Length mismatch");
        uint256[] memory balances = new uint256[](accounts.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            balances[i] = balanceOf[ids[i]][accounts[i]];
        }
        return balances;
    }
    
    function _mint(address to, uint256 id, uint256 amount) internal {
        balanceOf[id][to] += amount;
        emit TransferSingle(msg.sender, address(0), to, id, amount);
    }
    
    function _burn(address from, uint256 id, uint256 amount) internal {
        balanceOf[id][from] -= amount;
        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }
}

/**
 * @title ERC1155Mintable
 * @dev ERC1155 with mint capability
 */
contract ERC1155Mintable is ERC1155 {
    address public owner;
    mapping(uint256 => string) private _tokenURIs;
    
    constructor() {
        owner = msg.sender;
    }
    
    function mint(address to, uint256 id, uint256 amount) external {
        require(msg.sender == owner, "Not owner");
        _mint(to, id, amount);
    }
    
    function burn(uint256 id, uint256 amount) external {
        _burn(msg.sender, id, amount);
    }
    
    function setURI(uint256 id, string calldata tokenURI) external {
        require(msg.sender == owner, "Not owner");
        _tokenURIs[id] = tokenURI;
        emit URI(tokenURI, id);
    }
    
    function uri(uint256 id) external view returns (string memory) {
        return _tokenURIs[id];
    }
}
