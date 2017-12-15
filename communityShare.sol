pragma solidity ^0.4.0;

contract Item {
    address private owner;
    address private leasee;
    string private name;
    string private desc;
    uint private age;
    uint private value;
    bool private available;
    
    //Access modification - Func based on owner
    modifier ownerFunc {
        require(owner == msg.sender);                //Better than throw - deprecated to 'require'
        _;                                           //executes check BEFORE func in this case
    }
    
        modifier nonOwnerFunc {
        require(owner != msg.sender);                //Better than throw - deprecated to 'require'
        _;                                           //executes check BEFORE func in this case
    }
    
    modifier leaseeFunc {
        require(leasee == msg.sender);              //Better than throw - deprecated to 'require'
        _;                                          //executes check BEFORE func in this case
    }
    
    function Item (string nameIn, string descIn, uint valueIn) public {
        owner = msg.sender;
        name = nameIn;
        desc = descIn;
        age = 1;
        value = valueIn;
        available = true;
    }
    
    //Lease requires a payment to the Item/contrat address, part goes to owner as rent while the rest remains in contract
    function lease() public payable nonOwnerFunc {   
        require(available == true);                         //Item must be available to be leased
        if(msg.value >= value) {
            leasee = msg.sender;                            //leasee will be set to sender of funds
            address(owner).send(msg.value/4);               //Send owner 1/4 of value as rent - keep rest in contract address
            available = false;
        } else { return; }
    }
    
    //Only owner can verify the Item has been returned - remaining balance will be paid back to leasee
    function returnItem() public ownerFunc {
        if(this.balance > 0) { address(leasee).send(this.balance); }
        leasee = 0;                                         //Clear leasee address - no longer leasee
        available = true;
    }
    
    //If balance has been paid out to owner, renter can claiim ownership of Item
//    function claimItem() public leaseeFunc {
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
    function setLeasee(address leaseeAddrIn) ownerFunc {
        leasee = leaseeAddrIn;
    }
    
    function getLeasee() returns (address) {
        return leasee;
    }  
    
    //Only owner can set value for Item
    function setAvailability(bool availabilityIn) ownerFunc {
        available = availabilityIn;
    }
    
    function getAvailability() returns (bool) {
        return available;
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