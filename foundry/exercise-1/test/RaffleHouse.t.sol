// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RaffleHouse} from "../src/RaffleHouse.sol";
import {TicketNFT} from "../src/TicketNFT.sol";

error TicketPriceTooLow();
error RaffleAlreadyStarted();
error InvalidRaffleEndTime();
error InsufficientRaffleDuration();
error RaffleDoesNotExist();
error RaffleNotStarted();
error RaffleEnded();
error InvalidTicketPrice();
error RaffleNotEnded();
error WinnerAlreadyChosen();
error WinnerNotChosen();
error NotWinner();

contract RaffleHouseTest is Test {
    RaffleHouse public raffleHouse;
    address owner = makeAddr('owner');
    address buyer1 = makeAddr('buyer1');
    address buyer2 = makeAddr('buyer2');
    address buyer3 = makeAddr('buyer3');
    
    uint256 constant TICKET_PRICE = 0.1 ether;
    uint256 raffleStart = block.timestamp + 1 hours;
    uint256 raffleEnd = raffleStart + 2 hours;
    function setUp() public {
        vm.prank(owner);
        raffleHouse = new RaffleHouse();
        
        vm.deal(owner, 10 ether);
        vm.deal(buyer1, 10 ether);
        vm.deal(buyer2, 10 ether);
        vm.deal(buyer3, 10 ether);

      
    }
    
    function testCreateRaffle() public {
        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit RaffleHouse.RaffleCreated(0, TICKET_PRICE, raffleStart, raffleEnd, "TestRaffle", "TR");
        
        raffleHouse.createRaffle(
            TICKET_PRICE,
            raffleStart,
            raffleEnd,
            "TestRaffle",
            "TR"
        );
        
        assertEq(raffleHouse.getRaffleCount(), 1);
        
        RaffleHouse.Raffle memory raffle = raffleHouse.getRaffle(0);
        assertEq(raffle.ticketPrice, TICKET_PRICE);
        assertEq(raffle.raffleStart, raffleStart);
        assertEq(raffle.raffleEnd, raffleEnd);
        assertEq(raffle.winningTicketIndex, 0);
    }
    
    function testCreateRaffleInvalidParams() public {
        // Test zero ticket price
        vm.prank(owner);
        vm.expectRevert(TicketPriceTooLow.selector);
        raffleHouse.createRaffle(
            0,
            raffleStart,
            raffleEnd,
            "TestRaffle",
            "TR"
        );
        
        // Test raffle already started
        vm.prank(owner);
        vm.expectRevert(RaffleAlreadyStarted.selector);
        raffleHouse.createRaffle(
            TICKET_PRICE,
            block.timestamp - 1,
            raffleEnd,
            "TestRaffle",
            "TR"
        );
        
        // Test invalid end time
        vm.prank(owner);
        vm.expectRevert(InvalidRaffleEndTime.selector);
        raffleHouse.createRaffle(
            TICKET_PRICE,
            raffleStart,
            raffleStart,
            "TestRaffle",
            "TR"
        );
        
        // Test insufficient duration
        vm.prank(owner);
        vm.expectRevert(InsufficientRaffleDuration.selector);
        raffleHouse.createRaffle(
            TICKET_PRICE,
            raffleStart,
            raffleStart + 30 minutes,
            "TestRaffle",
            "TR"
        );
    }

    modifier createRaffle() {
        vm.prank(owner);
        raffleHouse.createRaffle(
            TICKET_PRICE,
            raffleStart,
            raffleEnd,
            "TestRaffle",
            "TR"
        );
        _;
    }
    
    function testBuyTicket() public createRaffle{
        // Warp to raffle start time
        vm.warp(raffleStart);
        
        // Buy a ticket
        vm.prank(buyer1);
        vm.expectEmit(true, true, true, false);
        emit RaffleHouse.TicketPurchased(0, buyer1, 0);
        
        raffleHouse.buyTicket{value: TICKET_PRICE}(0);
        
        // Check ticket ownership
        RaffleHouse.Raffle memory raffle = raffleHouse.getRaffle(0);
        assertEq(raffle.ticketsContract.ownerOf(0), buyer1);
        assertEq(raffle.ticketsContract.balanceOf(buyer1), 1);
        
        // Buy another ticket
        vm.prank(buyer2);
        raffleHouse.buyTicket{value: TICKET_PRICE}(0);
        
        assertEq(raffle.ticketsContract.ownerOf(1), buyer2);
        assertEq(raffle.ticketsContract.balanceOf(buyer2), 1);
    }
    
    function testBuyTicketErrors() public createRaffle{
        // Test raffle doesn't exist
        vm.prank(buyer1);
        vm.expectRevert(RaffleDoesNotExist.selector);
        raffleHouse.buyTicket{value: TICKET_PRICE}(1);
        
        // Test raffle not started
        vm.prank(buyer1);
        vm.expectRevert(RaffleNotStarted.selector);
        raffleHouse.buyTicket{value: TICKET_PRICE}(0);
        
        // Warp to raffle start time
        vm.warp(raffleStart);
        
        // Test invalid ticket price
        vm.prank(buyer1);
        vm.expectRevert(InvalidTicketPrice.selector);
        raffleHouse.buyTicket{value: 0.05 ether}(0);
        
        // Warp to after raffle end
        vm.warp(raffleEnd + 1);
        
        // Test raffle ended
        vm.prank(buyer1);
        vm.expectRevert(RaffleEnded.selector);
        raffleHouse.buyTicket{value: TICKET_PRICE}(0);
    }
    
    function testChooseWinner() public createRaffle{
        // Warp to raffle start time and buy tickets
        vm.warp(raffleStart);
        
        vm.prank(buyer1);
        raffleHouse.buyTicket{value: TICKET_PRICE}(0);
        
        vm.prank(buyer2);
        raffleHouse.buyTicket{value: TICKET_PRICE}(0);
        
        vm.prank(buyer3);
        raffleHouse.buyTicket{value: TICKET_PRICE}(0);
        
        // Warp to after raffle end
        vm.warp(raffleEnd + 1);
        
        // Choose winner
        vm.expectEmit(true, true, false, false);
        emit RaffleHouse.WinnerChosen(0, 0); // We can't predict the actual winning index
        
        raffleHouse.chooseWinner(0);
        
        // Check winner was set
        RaffleHouse.Raffle memory raffle = raffleHouse.getRaffle(0);
        assertTrue(raffle.winningTicketIndex > 0);
        assertTrue(raffle.winningTicketIndex < raffle.ticketsContract.totalSupply());
    }
    //bug in choose winner with 1 participant
    function testChooseWinnerErrors() public createRaffle {
        // Test raffle doesn't exist
        vm.expectRevert(RaffleDoesNotExist.selector);
        raffleHouse.chooseWinner(1);
        
        // Test raffle not ended
        vm.expectRevert(RaffleNotEnded.selector);
        raffleHouse.chooseWinner(0);
        
        // Warp to raffle start time and buy tickets
        vm.warp(raffleStart);
        
        vm.prank(buyer1);
        raffleHouse.buyTicket{value: TICKET_PRICE}(0);
        
        // Warp to after raffle end
        vm.warp(raffleEnd + 1);
        
        // Choose winner
        raffleHouse.chooseWinner(0);
        
        // Test winner already chosen
        vm.expectRevert(WinnerAlreadyChosen.selector);
        raffleHouse.chooseWinner(0);

    }
    
    function testClaimPrize() public createRaffle{
        // Warp to raffle start time and buy tickets
        vm.warp(raffleStart);
        
        vm.prank(buyer1);
        raffleHouse.buyTicket{value: TICKET_PRICE}(0);
        
        vm.prank(buyer2);
        raffleHouse.buyTicket{value: TICKET_PRICE}(0);
        
        vm.prank(buyer3);
        raffleHouse.buyTicket{value: TICKET_PRICE}(0);
        
        // Warp to after raffle end
        vm.warp(raffleEnd + 1);
        
        // // Get raffle after winner chosen
        RaffleHouse.Raffle memory raffle = raffleHouse.getRaffle(0);
        raffleHouse.chooseWinner(0);
        
        // Directly set the winner to buyer2 (ticket 1)
        uint256 slot = 4; // raffles mapping slot
        bytes32 key = keccak256(abi.encode(uint256(0),slot));
        uint256 winningTicketSlotOffset = 4;
        
        vm.store(
            address(raffleHouse),
            bytes32(uint256(key) + winningTicketSlotOffset),
            bytes32(uint256(1)) // Set winning ticket to 1
        );
        
        // Buyer1 claims prize
        uint256 balanceBefore = buyer2.balance;
        
        // Approve the raffle contract to transfer the winning ticket
        TicketNFT ticketsContract = raffle.ticketsContract;
        vm.prank(buyer2);
        ticketsContract.approve(address(raffleHouse), raffle.winningTicketIndex);
        
        vm.expectEmit(true, true, true, false);
        emit RaffleHouse.PrizeClaimed(0, buyer2, TICKET_PRICE * 3);
        
        vm.prank(buyer2);
        raffleHouse.claimPrize(0);
        
        // Check buyer2 received the prize
        uint256 balanceAfter = buyer2.balance;
        assertEq(balanceAfter - balanceBefore, TICKET_PRICE * 3);
    }
    
    function testClaimPrizeErrors() public createRaffle {

        // Test raffle doesn't exist
        vm.prank(buyer1);
        vm.expectRevert(RaffleDoesNotExist.selector);
        raffleHouse.claimPrize(1);
        
        // Test raffle not ended
        vm.prank(buyer1);
        vm.expectRevert(RaffleNotEnded.selector);
        raffleHouse.claimPrize(0);
        
        // Warp to raffle start time and buy tickets
        vm.warp(raffleStart);
        
        vm.prank(buyer1);
        raffleHouse.buyTicket{value: TICKET_PRICE}(0);
        
        vm.prank(buyer2);
        raffleHouse.buyTicket{value: TICKET_PRICE}(0);
        
        // Warp to after raffle end
        vm.warp(raffleEnd + 1);
        
        // Test winner not chosen
        vm.prank(buyer1);
        vm.expectRevert(WinnerNotChosen.selector);
        raffleHouse.claimPrize(0);
        
        // Choose winner (setting to ticket 1 owned by buyer2)
        raffleHouse.chooseWinner(0);
        
        // Directly set the winner to buyer2 (ticket 1)
        uint256 slot = 4; // raffles mapping slot
        bytes32 key = keccak256(abi.encode(uint256(0), slot));
        uint256 winningTicketSlotOffset = 4;
        
        vm.store(
            address(raffleHouse),
            bytes32(uint256(key) + winningTicketSlotOffset),
            bytes32(uint256(1)) // Set winning ticket to 1
        );
        
        // Test not winner
        vm.prank(buyer1);
        vm.expectRevert(NotWinner.selector);
        raffleHouse.claimPrize(0);
    }
    
    function testEndToEndRaffle() public createRaffle{
        // Warp to raffle start time
        vm.warp(block.timestamp + 1 hours);
        
        // Multiple users buy tickets
        for (uint i = 0; i < 5; i++) {
            address buyer = makeAddr(string(abi.encodePacked("buyer", i)));
            vm.deal(buyer, TICKET_PRICE);
            vm.prank(buyer);
            raffleHouse.buyTicket{value: TICKET_PRICE}(0);
        }
        
        // Warp to after raffle end
        vm.warp(raffleEnd + 1);
        
        // Choose winner
        raffleHouse.chooseWinner(0);
        
        // Get the winner
        RaffleHouse.Raffle memory raffle = raffleHouse.getRaffle(0);
        address winner = raffle.ticketsContract.ownerOf(raffle.winningTicketIndex);
        
        // Winner approves tickets contract
        vm.prank(winner);
        raffle.ticketsContract.approve(address(raffleHouse), raffle.winningTicketIndex);
        
        // Winner claims prize
        uint256 balanceBefore = winner.balance;
        
        vm.prank(winner);
        raffleHouse.claimPrize(0);
        
        // Check winner got the prize
        uint256 balanceAfter = winner.balance;
        assertEq(balanceAfter - balanceBefore, TICKET_PRICE * 5);
        
        // Check winning ticket is transferred to contract
        assertEq(raffle.ticketsContract.ownerOf(raffle.winningTicketIndex), address(raffleHouse));
    }
    
    function testRaffleGetRaffleCount() public {
        assertEq(raffleHouse.getRaffleCount(), 0);
    
        // Create 3 raffles
        for (uint i = 0; i < 3; i++) {
            vm.prank(owner);
            raffleHouse.createRaffle(
                TICKET_PRICE,
                raffleStart,
                raffleEnd,
                string(abi.encodePacked("Raffle", i)),
                string(abi.encodePacked("R", i))
            );
        }
        
        assertEq(raffleHouse.getRaffleCount(), 3);
    }
}