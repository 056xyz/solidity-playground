// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../src/StandardERC20Optimized.sol";

contract OptimizedERC20Test is Test {
    OptimizedERC20 token;
    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        token = new OptimizedERC20("TestToken", "TT", 18, 1000 ether);
    }

    function testInitialMint() public {
        assertEq(token.balanceOf(address(this)), 1000 ether);
    }

    function testTransfer() public {
        vm.prank(address(this));
        token.transfer(alice, 200 ether);

        assertEq(token.balanceOf(alice), 200 ether);
        assertEq(token.balanceOf(address(this)), 800 ether);
    }

    function testTransferRevertsIfInsufficientBalance() public {
        vm.expectRevert();
        vm.prank(alice);
        token.transfer(bob, 100 ether); 
    }
    function testApproveAndTransferFrom() public {
        token.approve(alice, 300 ether);

        vm.prank(alice);
        token.transferFrom(address(this), bob, 300 ether);

        assertEq(token.balanceOf(bob), 300 ether);
        assertEq(token.balanceOf(address(this)), 700 ether);
        assertEq(token.allowance(address(this), alice), 0);
    }

    function testMaxAllowanceSkipsDecrement() public {
        token.approve(alice, type(uint256).max);

        vm.prank(alice);
        token.transferFrom(address(this), bob, 100 ether);

        assertEq(token.allowance(address(this), alice), type(uint256).max);
    }

   

    function testTransferFromRevertsIfInsufficientAllowance() public {
        token.approve(alice, 50 ether);

        vm.expectRevert();
        vm.prank(alice);
        token.transferFrom(address(this), bob, 100 ether);
    }

    function testTransferFromRevertsIfInsufficientBalance() public {
        vm.prank(address(this));
        token.approve(alice, 100 ether);

        vm.expectRevert();
        vm.prank(alice);
        token.transferFrom(address(this), bob, 1000 ether);
    }
}
