// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract DigitalLibrary {
    
    error ExpiredEBook();
    error NotPrimaryLibrarian();
    error NotAuthorizedLibrarian();
    
    enum Status { 
        Active,
        Outdated,
        Archived
    }

    struct EBook {
        string title;
        string author;
        string publicationDate; 
        uint expirationDate;
        Status status;
        address primaryLibrarian;
        uint readCount;
    }

    mapping (uint => address[]) public authorizedLibrarians;
    mapping (uint => EBook) public books;

    function createEBook(string calldata _title, string calldata _author, string memory _publicationDate) public returns (uint) {
        uint id = uint(keccak256(abi.encodePacked(_title, block.timestamp)));

        EBook memory book;
        book.title = _title;
        book.author = _author;
        book.publicationDate = _publicationDate;
        book.expirationDate = block.timestamp + 180 days;
        book.status = Status.Active;
        book.primaryLibrarian = msg.sender;

        books[id] = book;

        return id;
    }


    function addLibrarian(uint id, address additionalLibrarian) public {
        EBook storage currBook = books[id];

        if (currBook.primaryLibrarian != msg.sender) {
            revert NotPrimaryLibrarian();
        }

        authorizedLibrarians[id].push(additionalLibrarian);
    }


    function extendDate(uint id) public {
        EBook storage currBook = books[id];
        bool isAuthorized;
        
        // if (currBook.primaryLibrarian != msg.sender) {
        //     revert NotPrimaryLibrarian();
        // }

        address[] memory librarians = authorizedLibrarians[id];
        for (uint i = 0; i < librarians.length; i++) {
           address currLibrarian = librarians[i];

           if (currLibrarian == msg.sender) {
            isAuthorized = true;
           } 
        }

        if (!isAuthorized && currBook.primaryLibrarian != msg.sender) {
            revert NotAuthorizedLibrarian();
        }

        currBook.expirationDate = block.timestamp + 180 days;
    }

    function changeStatus(Status _status, uint id) public {
        EBook storage currBook = books[id];
        if (currBook.primaryLibrarian != msg.sender) {
            revert NotPrimaryLibrarian();
        }

        currBook.status = _status;
    }


    function checkExpiration(uint id) public returns(string memory expiration){
       EBook storage currBook = books[id];
       currBook.readCount++;

       if (currBook.expirationDate < block.timestamp) {
            expiration =  "outdated";
       } else {
            expiration =  "Not Expired";
       }
    }
}