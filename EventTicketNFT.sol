// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract EventTicketNFT is ERC721, Ownable(msg.sender) {
    error PurchaseWindowNotClosed();
    error PurchaseWindowClosed();
    error TicketsLimit();
    error TransferNotAuthorized();
    error NotEnoughEth(uint value, uint ticketPrice);

    event EventCreated(uint256 indexed eventId);
    event TicketSold(uint256 indexed eventId, address indexed buyer, uint256 price);
    event MintedNFT(uint256 indexed eventId, address indexed buyer, uint256 nftId);
    event TransferAuthorized(uint256 indexed eventId, uint256 indexed token);
    
    mapping(uint256 eventId => address[] users) private tickets;
    mapping(uint256 eventId => Metadata _event) private events;
    mapping(uint256 eventId => mapping(address => uint256)) private seats;
    mapping(uint256 eventId => mapping (uint256 tokenId => bool isAuthorized)) private authorized;
    uint256 private eventIdCounter;
    uint256 private ticketIdCounter;

    struct Metadata {
        string eventName;
        string date;
        uint256 ticketPrice;
        uint256 ticketsLimit;
        uint256 purchaseStart;
        uint256 purchaseTimePeriod;
    }

    constructor () ERC721 ("EventTicketNFT", "ETN") {}
    
    function createEvent(
        string calldata _eventName, 
        string calldata _date, 
        uint256 _purchaseTimePeriod,
        uint256 _ticketPrice,
        uint256 _ticketsLimit
        ) private onlyOwner {
            events[eventIdCounter] = Metadata({
                eventName: _eventName, 
                date: _date, 
                ticketPrice: _ticketPrice,
                ticketsLimit: _ticketsLimit,
                purchaseStart: block.timestamp + 1 days,
                purchaseTimePeriod: _purchaseTimePeriod
            });
            emit EventCreated(eventIdCounter);

            eventIdCounter++;
    }
    
    function buyTicket (uint256 eventId) public payable {
        Metadata memory _event = events[eventId];

        if (msg.value < _event.ticketPrice) {
            revert NotEnoughEth(msg.value, _event.ticketPrice);
        }

        if (block.timestamp > _event.purchaseStart + _event.purchaseTimePeriod) {
            revert PurchaseWindowClosed();
        }

        if (tickets[eventId].length > _event.ticketsLimit) {
            revert TicketsLimit();
        }

        tickets[eventId].push(msg.sender);
        emit TicketSold(eventId, msg.sender, msg.value);
    }

    modifier isAuthorized(uint256 tokenId, uint256 eventId) {
        if (!authorized[eventId][tokenId]) {
            revert TransferNotAuthorized();
        }
        _;
    }
    function transferTicket (address to, uint256 tokenId, uint256 eventId) public isAuthorized(tokenId, eventId) {
        uint256 changedOwnerSeat = seats[eventId][msg.sender];
        seats[eventId][to] = changedOwnerSeat;
        delete seats[eventId][msg.sender];
        _safeTransfer(msg.sender, to, tokenId);
    }

    function toggleAuthorize(uint256 eventId, uint256 tokenId) private onlyOwner {
        authorized[eventId][tokenId] = !authorized[eventId][tokenId];
        emit TransferAuthorized(eventId, tokenId);
    }

    function mintEvent(uint256 eventId) private onlyOwner {
        Metadata memory _event = events[eventId];
        if (_event.purchaseStart + _event.purchaseTimePeriod < block.timestamp) {
            revert PurchaseWindowNotClosed();
        }

        uint256 length = tickets[eventId].length;
        for (uint256 i = 0; i < length; i++) {
            _safeMint(tickets[eventId][i], ticketIdCounter);
            seats[eventId][tickets[eventId][i]] = i;
            ticketIdCounter++;

            // might be redundant, safeMint must be emitting? ..check later again
            emit MintedNFT(eventId, tickets[eventId][i], ticketIdCounter);
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }
    // how to override/remove old tokenURI fn
    function _tokenURI(uint256 eventId, uint256 tokenId) public view returns (string memory) {

        tokenURI(tokenId);
        _requireOwned(tokenId);

        uint256 seat = seats[eventId][msg.sender];
        Metadata memory _event = events[eventId];
        string memory name = _event.eventName;
        string memory date = _event.date;
        uint256 ticketPrice = _event.ticketPrice;
        uint256 ticketsLimit = _event.ticketsLimit;


       return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        string.concat(
                            '{"name":"',
                            name,
                            '", "date":"',
                            date,
                            '", "settings": [{"ticketPrice": "',
                            Strings.toString(ticketPrice),
                            '", "ticketsLimit": "',
                            Strings.toString(ticketsLimit),
                            '"}], "seat":"',
                            Strings.toString(seat),
                            '"}'
                        )
                    )
                )
            )
        );
    }
}
