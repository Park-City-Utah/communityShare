pragma solidity ^0.4.0;

contract Item {
    address private owner;
    string private name;
    string private desc;
    uint private age;
    uint private value;
    address private renter;
    
    //Access modification - Func based on owner
    modifier ownerFunc {
        require(owner == msg.sender);                 //Better than throw - deprecated to 'require'
        _;                                            //executes check BEFORE func in this case
    }
    
        modifier nonOwnerFunc {
        require(owner != msg.sender);                  //Better than throw - deprecated to 'require'
        _;                                             //executes check BEFORE func in this case
    }
    
    modifier renterFunc {
        require(renter == msg.sender);                  //Better than throw - deprecated to 'require'
        _;                                             //executes check BEFORE func in this case
    }
    
    function Item (string nameIn, string descIn, uint valueIn) public {
        owner = msg.sender;
        name = nameIn;
        desc = descIn;
        age = 1;
        value = valueIn;
    }
    
    //Rent requires a payment to the Item, part goes to owner as rent while the rest remains in contract
    function rent() public payable nonOwnerFunc {   
        if(msg.value >= value) {
            renter = msg.sender;                            //renter will be set to sender of funds
            address(owner).send(msg.value/4);               //Send owner 1/4 of value as rent - keep rest in contract address
        } else { return; }
    }
    
    //Only owner can verify the Item has been returned - remaining balance will be paid back to renter
    function returnItem() public ownerFunc {
        if(this.balance > 0) { address(renter).send(this.balance); }
    }
    
    //If balance has been paid out to owner, renter can claiim ownership of Item
//    function claimItem() public renterFunc {
//        if(this.balance < 1) { owner = renter; }            //Renter now becomes the owner
//    }
    
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
    
    //Only owner can set value for Item
    function setRenter(address renterAddrIn) ownerFunc {
        renter = renterAddrIn;
    }
    
    function getRenter() returns (address) {
        return renter;
    }  
    
    function getOwner() returns (address) {
        return owner;
    }
    
    function getBalance() returns (uint) {
        return this.balance;
    }   
    
    //Kill instance of contract or kill contract on blockchain?
    function kill() ownerFunc {
        selfdestruct(owner);
    }
}