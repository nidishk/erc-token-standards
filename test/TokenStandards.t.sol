// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ERC20.sol";
import "../src/ERC721.sol";
import "../src/ERC1155.sol";

contract ERC20Test is Test {
    ERC20Mintable token;
    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        token = new ERC20Mintable("Test Token", "TEST");
        token.mint(alice, 1000 ether);
    }

    function testName() public view {
        assertEq(token.name(), "Test Token");
    }

    function testMint() public view {
        assertEq(token.balanceOf(alice), 1000 ether);
        assertEq(token.totalSupply(), 1000 ether);
    }

    function testTransfer() public {
        vm.prank(alice);
        token.transfer(bob, 100 ether);
        assertEq(token.balanceOf(alice), 900 ether);
        assertEq(token.balanceOf(bob), 100 ether);
    }

    function testApproveAndTransferFrom() public {
        vm.prank(alice);
        token.approve(bob, 500 ether);
        assertEq(token.allowance(alice, bob), 500 ether);
        
        vm.prank(bob);
        token.transferFrom(alice, bob, 200 ether);
        assertEq(token.balanceOf(bob), 200 ether);
        assertEq(token.allowance(alice, bob), 300 ether);
    }

    function testBurn() public {
        vm.prank(alice);
        token.burn(100 ether);
        assertEq(token.balanceOf(alice), 900 ether);
        assertEq(token.totalSupply(), 900 ether);
    }
}

contract ERC721Test is Test {
    ERC721Mintable nft;
    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        nft = new ERC721Mintable("Test NFT", "TNFT");
    }

    function testMint() public {
        uint256 tokenId = nft.mint(alice);
        assertEq(tokenId, 0);
        assertEq(nft.ownerOf(0), alice);
        assertEq(nft.balanceOf(alice), 1);
    }

    function testTransfer() public {
        nft.mint(alice);
        vm.prank(alice);
        nft.transferFrom(alice, bob, 0);
        assertEq(nft.ownerOf(0), bob);
        assertEq(nft.balanceOf(alice), 0);
        assertEq(nft.balanceOf(bob), 1);
    }

    function testApprove() public {
        nft.mint(alice);
        vm.prank(alice);
        nft.approve(bob, 0);
        assertEq(nft.getApproved(0), bob);
        
        vm.prank(bob);
        nft.transferFrom(alice, bob, 0);
        assertEq(nft.ownerOf(0), bob);
    }

    function testSetApprovalForAll() public {
        nft.mint(alice);
        vm.prank(alice);
        nft.setApprovalForAll(bob, true);
        assertTrue(nft.isApprovedForAll(alice, bob));
        
        vm.prank(bob);
        nft.transferFrom(alice, bob, 0);
        assertEq(nft.ownerOf(0), bob);
    }
}

contract ERC1155Test is Test {
    ERC1155Mintable token;
    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        token = new ERC1155Mintable();
    }

    function testMint() public {
        token.mint(alice, 1, 100);
        assertEq(token.balanceOf(1, alice), 100);
    }

    function testTransfer() public {
        token.mint(alice, 1, 100);
        vm.prank(alice);
        token.safeTransferFrom(alice, bob, 1, 50, "");
        assertEq(token.balanceOf(1, alice), 50);
        assertEq(token.balanceOf(1, bob), 50);
    }

    function testBatchTransfer() public {
        token.mint(alice, 1, 100);
        token.mint(alice, 2, 200);
        
        uint256[] memory ids = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;
        
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 50;
        amounts[1] = 100;
        
        vm.prank(alice);
        token.safeBatchTransferFrom(alice, bob, ids, amounts, "");
        
        assertEq(token.balanceOf(1, bob), 50);
        assertEq(token.balanceOf(2, bob), 100);
    }

    function testSetURI() public {
        token.setURI(1, "https://example.com/1");
        assertEq(token.uri(1), "https://example.com/1");
    }
}
