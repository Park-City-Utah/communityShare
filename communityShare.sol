pragma solidity ^0.4.0;

contract Item {
    address private owner;
    address private leasee;
    string private name;
    string private desc;
    uint private created;
    uint private leasedTime;       
    uint private value;
    bool private available;
    uint private balance;
    //uint private timeSinceRentCollected;
    
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
    
    //Constructor
    constructor (string name_, string desc_, uint value_) public {
        owner = msg.sender;
        name = name_;
        desc = desc_;
        created = block.timestamp;
        value = value_;
        available = true;
        balance = getBalance();
    }
    
    //Lease requires a payment to the Item/contract address, part goes to owner as rent while the rest remains in contract
    function lease() public payable nonOwnerFunc {   
        require(available && msg.value == value);           //Item must be available to be leased
            leasee = msg.sender;                            //leasee will be set to sender of funds
            address(owner).transfer(msg.value/4);           //Send owner 1/4 of value as rent - keep rest in contract address
            available = false;
            leasedTime = block.timestamp;
    }
    
    //Only owner can verify the Item has been returned - remaining balance will be paid back to leasee
    function returnItem() public ownerFunc {
        require(available == false);               //Can't return an non leased item
        if (address(this).balance > 0) { leasee.transfer(getBalance()); }
        leasee = 0;                                         //Clear leasee address - no longer leasee
        available = true;
        leasedTime = 0;                                         //Reset leased timestamp
    }
    
    //Allow owner to collect rent based on time passed since rented
    /*function collectRent() public ownerFunc {
         require(available == false); 
         uint amount = 0;
         if(timeSinceRentCollected > created) { 
             amount = block.timestamp - timeSinceRentCollected / 86400;
         }
         else {
             amount = block.timestamp - created / 86400;
             
         }
         address(owner).transfer(amount);                                   
    } */   
    
    //Only leasee can pay towards balance - can trigger claim of ownership
    function payOut() public leaseeFunc  {
        require(available == false);
        address(owner).transfer(getBalance());              //Send funds to owner from Item wallet
        //claimItem
    }
    
    //If balance has been paid out to owner, renter can claim ownership of Item
    function claimItem() public leaseeFunc {
        require(getBalance() == 0);
        owner = leasee;                                     //Renter now becomes the owner
    }

//Todo: transfer funds daily
//Todo: check balance and call claimItem after event
    
    //Only owner can set value for Item    
    function setName(string newName) public ownerFunc {
        name = newName;
    }
    
    function getName() returns (string) {
        return name;
    }
    
    //Current timestamp minus created timestamp
    function getAge() returns (uint) {
        return block.timestamp - created;
    }
    
    //Current timestamp minus leased timstamp
    function getLeasedTime() returns (uint) {
        require(leasedTime > 0 && available == false);                            
        return block.timestamp - leasedTime;
    }
    
    //Only owner can set desc Item
    function setDesc(string desc_) ownerFunc {
        desc = desc_;
    }
    
    function getDesc() returns (string) {
        return desc;
    }
    
    //Only owner can set value for Item
    function setValue(uint value_) ownerFunc {
        require(available);                                 //Cannot change value while being rented 
        value = value_;
    }
    
    function getValue() returns (uint) {
        return value;
    }
    
    //Get is public
    function getLeasee() returns (address) {
        return leasee;
    }  
    
    //Set availablity can only be done by return of item or change in ownership
    
    //Get is public
    function getAvailability() returns (bool) {
        return available;
    }
    
    //Get is public
    function getOwner() returns (address) {
        return owner;
    }
    
    //Get is public
    function getBalance() returns (uint) {
        return address(this).balance;
    }   
    
    //Kill instance of contract or kill contract on blockchain?
    function kill() ownerFunc {
        selfdestruct(this);
    }
}