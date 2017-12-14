pragma solidity ^0.4.0;

contract Item {
    address private owner;
    string private name;
    string private desc;
    uint private age;
    uint private value;
    
    //Access modification - Func based on owner
    modifier ownerFunc{
        require(owner == msg.sender);               //Better than throw - deprecated to 'require'
        _;                                          //executes check BEFORE func in this case
    }
    
    function Item (string nameIn, string descIn, uint valueIn) public {
        owner = msg.sender;
        name = nameIn;
        desc = descIn;
        age = 1;
        value = valueIn;
    }
    
    //Rent object requires a payment to the Item, part goes to owner as rent while the rest remains in contract
    function rent(uint rentAmount) public payable {   
        if(rentAmount == value) {
            //Send owner 1/4 of value as rent - keep rest in contract address
            address(owner).send(msg.value/4);
        }
        else {
            return;
        }
    }
    
    //Only owner can set value for Item    
    function setName(string newName) ownerFunc {
        name = newName;
    }
    
    function getName() returns (string) {
        return name;
    }
    
    //Only owner can set value for Item
    function setAge(uint newAge) ownerFunc {
        age = newAge;
    }
    
    function getAge() returns (uint) {
        return age;
    }
    
    //Only owner can set value for Item
    function setDesc(uint newAge) ownerFunc {
        age = newAge;
    }
    
    function getDesc() returns (uint) {
        return age;
    }
    
    //Only owner can set value for Item
    function setValue(uint valueIn) ownerFunc {
        value = valueIn;
    }
    
    function getValue() returns (uint) {
        return value;
    }
}