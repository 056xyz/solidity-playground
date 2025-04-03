pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TicketNFT} from "../src/TicketNFT.sol";

contract TicketNFTTest is Test {
    TicketNFT public ticketNFT;
    address owner = makeAddr('owner');
    address user = makeAddr('user');
    // vm.expectEmit(true, true, true, true);
    // vm.expectRevert(abi.encodeWithSelector(CustomError.selector, param1, param2));
    // emit Transfer(address(0), user, 0);
    function setUp() public {
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        ticketNFT = new TicketNFT('testName', 'testSymbol');
    }

    function testInitialState() public {
        assertEq(ticketNFT.getNextTokenId(), 0);
        assertEq(ticketNFT.owner(), owner);
    }
 
    function testNftMint() public {
        vm.startPrank(owner);
        
        // Mint a token and verify tokenId
        uint256 tokenId = ticketNFT.safeMint(user);
        assertEq(tokenId, 0);
        
        // Check token owner
        assertEq(ticketNFT.ownerOf(tokenId), user);
        
        // Check balances
        assertEq(ticketNFT.balanceOf(user), 1);
        
        // Mint another token
        uint256 tokenId2 = ticketNFT.safeMint(owner);
        assertEq(tokenId2, 1);
        assertEq(ticketNFT.ownerOf(tokenId2), owner);
        
        // Verify nextTokenId has increased
        assertEq(ticketNFT.getNextTokenId(), 2);
        
        vm.stopPrank();
    }  

    function testOwnershipTransfer() public {
        // Test two-step ownership transfer
        vm.startPrank(owner);
        
        // First step: propose new owner
        ticketNFT.transferOwnership(user);
        
        // Owner should still be the original owner
        assertEq(ticketNFT.owner(), owner);
        
        // Check pending owner
        assertEq(ticketNFT.pendingOwner(), user);
        
        vm.stopPrank();
        
        // Non-pending owner cannot accept ownership
        vm.prank(address(0x123));
        vm.expectRevert();
        ticketNFT.acceptOwnership();
        
        // Pending owner accepts ownership
        vm.prank(user);
        ticketNFT.acceptOwnership();
        
        // Verify owner changed
        assertEq(ticketNFT.owner(), user);
        
        // Old owner can no longer mint
        vm.prank(owner);
        vm.expectRevert();
        ticketNFT.safeMint(owner);
        
        // New owner can mint
        vm.prank(user);
        uint256 tokenId = ticketNFT.safeMint(user);
        assertEq(ticketNFT.ownerOf(tokenId), user);
    }


    function testERC721InterfaceCompliance() public {
        bytes4 erc721InterfaceId = 0x80ac58cd; // ERC721 interface ID
        assertTrue(ticketNFT.supportsInterface(erc721InterfaceId));
        
        bytes4 erc721EnumerableInterfaceId = 0x780e9d63; // ERC721Enumerable interface ID
        assertTrue(ticketNFT.supportsInterface(erc721EnumerableInterfaceId));
        
        bytes4 erc165InterfaceId = 0x01ffc9a7; // ERC165 interface ID
        assertTrue(ticketNFT.supportsInterface(erc165InterfaceId));
    } 

    function testEnumeration() public {
        vm.startPrank(owner);
        
        ticketNFT.safeMint(user); // tokenId 0
        ticketNFT.safeMint(owner); // tokenId 1
        ticketNFT.safeMint(user); // tokenId 2
        ticketNFT.safeMint(user); // tokenId 3
        
        assertEq(ticketNFT.totalSupply(), 4);
        
        assertEq(ticketNFT.tokenByIndex(0), 0);
        assertEq(ticketNFT.tokenByIndex(1), 1);
        assertEq(ticketNFT.tokenByIndex(2), 2);
        assertEq(ticketNFT.tokenByIndex(3), 3);
        
        assertEq(ticketNFT.balanceOf(user), 3);
        assertEq(ticketNFT.tokenOfOwnerByIndex(user, 0), 0);
        assertEq(ticketNFT.tokenOfOwnerByIndex(user, 1), 2);
        assertEq(ticketNFT.tokenOfOwnerByIndex(user, 2), 3);
        
        assertEq(ticketNFT.balanceOf(owner), 1);
        assertEq(ticketNFT.tokenOfOwnerByIndex(owner, 0), 1);
        
        vm.stopPrank();
    }

    // function testOnlyOwner() public {
    //     // Test that only owner can mint
    //     vm.prank(owner);
    //     uint256 tokenId = ticketNFT.safeMint(owner);
    //     assertEq(ticketNFT.ownerOf(tokenId), owner);
        
    //     // Non-owner trying to mint should revert
    //     vm.prank(user);
    //     vm.expectRevert("Ownable: caller is not the owner");
    //     ticketNFT.safeMint(user);
    // }
    
    function testTransferToken() public {
        vm.prank(owner);
        uint256 tokenId = ticketNFT.safeMint(owner);
        
        vm.prank(owner);
        ticketNFT.transferFrom(owner, user, tokenId);
        
        assertEq(ticketNFT.ownerOf(tokenId), user);
        assertEq(ticketNFT.balanceOf(owner), 0);
        assertEq(ticketNFT.balanceOf(user), 1);
    }
}
