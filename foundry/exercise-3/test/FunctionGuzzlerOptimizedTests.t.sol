// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../src/FunctionGuzzlerOptimized.sol";

contract FunctionGuzzlerTest is Test {
    FunctionGuzzler public guzzler;
    address user1 = address(0x1);
    address user2 = address(0x2);
    address user3 = address(0x3);

    function setUp() public {
        guzzler = new FunctionGuzzler();
    }

    function testRegisterUser() public {
        vm.prank(user1);
        guzzler.registerUser();
        assertTrue(guzzler.isUser(user1));
    }

    function testRevertAlreadyRegistered() public {
        vm.prank(user1);
        guzzler.registerUser();

        vm.prank(user1);
        vm.expectRevert(FunctionGuzzler.AlreadyRegistered.selector);
        guzzler.registerUser();
    }

    function testAddValue() public {
        vm.prank(user1);
        guzzler.registerUser();

        vm.prank(user1);
        guzzler.addValue(10);

        assertEq(guzzler.totalValue(), 10);
        assertEq(guzzler.getAverageValue(), 10);
        assertTrue(guzzler.valueExists(10));
        
    }

    function testRevertValueAlreadyExists() public {
        vm.prank(user1);
        guzzler.registerUser();

        vm.startPrank(user1);
        guzzler.addValue(42);
        vm.expectRevert(FunctionGuzzler.ValueAlreadyExists.selector);
        guzzler.addValue(42);
        vm.stopPrank();
    }

    function testRevertNotRegisteredAddValue() public {
        vm.expectRevert(FunctionGuzzler.NotRegistered.selector);
        guzzler.addValue(100);
    }

    function testDeposit() public {
        vm.prank(user1);
        guzzler.registerUser();

        vm.prank(user1);
        guzzler.deposit(500);

        assertEq(guzzler.totalValue(), 500);
        assertEq(guzzler.balances(user1), 500);
    }

    function testRevertNotRegisteredDeposit() public {
        vm.expectRevert(FunctionGuzzler.NotRegistered.selector);
        guzzler.deposit(1000);
    }

    function testTransfer() public {
        vm.startPrank(user1);
        guzzler.registerUser();
        guzzler.deposit(1000);
        vm.stopPrank();

        vm.prank(user2);
        guzzler.registerUser();

        vm.prank(user1);
        guzzler.transfer(user2, 400);

        assertEq(guzzler.balances(user1), 600);
        assertEq(guzzler.balances(user2), 400);
    }

    function testTransferRevertsSenderNotRegistered() public {
        vm.expectRevert(FunctionGuzzler.SenderNotRegistered.selector);
        guzzler.transfer(user2, 100);
    }

    function testTransferRevertsRecipientNotRegistered() public {
        vm.prank(user1);
        guzzler.registerUser();

        vm.expectRevert(FunctionGuzzler.RecipientNotRegistered.selector);
        vm.prank(user1);
        guzzler.transfer(user2, 100);
    }

    function testTransferRevertsInsufficientBalance() public {
        vm.startPrank(user1);
        guzzler.registerUser();
        guzzler.deposit(50);
        vm.stopPrank();

        vm.prank(user2);
        guzzler.registerUser();

        vm.prank(user1);
        vm.expectRevert(FunctionGuzzler.InsufficientBalance.selector);
        guzzler.transfer(user2, 100);
    }

    function testAverageWithMultipleValues() public {
        vm.prank(user1);
        guzzler.registerUser();

        vm.startPrank(user1);
        guzzler.addValue(10);
        guzzler.addValue(20);
        guzzler.addValue(30);
        vm.stopPrank();

        assertEq(guzzler.getAverageValue(), 20);
    }

    function testAverageWithNoValues() public {
        assertEq(guzzler.getAverageValue(), 0);
    }
}
