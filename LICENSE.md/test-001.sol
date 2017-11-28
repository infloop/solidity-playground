pragma solidity ^0.4.16;
contract BusinessCardBook {
    
    struct Contact {
        string name;
        uint age;
        string phone;
    }
    
    mapping(address => Contact) book;
    
    function getName() constant public returns (string) {
        return book[msg.sender].name;
    }
    
    function setName(string newName) public {
        Contact storage personalBook = book[msg.sender];
        personalBook.name = newName;
    }
    
    function getAge() constant public returns (uint) {
        return book[msg.sender].age;
    }
    
    function setAge(uint newAge) public {
        Contact storage personalBook = book[msg.sender];
        personalBook.age = newAge;
    }
    
    function getPhone() constant public returns (string) {
        return book[msg.sender].phone;
    }
    
    function setPhone(string newPhone) public {
        Contact storage personalBook = book[msg.sender];
        personalBook.phone = newPhone;
    }
}
