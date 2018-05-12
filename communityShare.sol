pragma solidity ^0.4.0;

contract Owned {
    address owner;
    
    constructor () public {
        owner == msg.sender;
    }
    
    //Access modification - Func based on owner
    modifier ownerFunc {
        require(owner == msg.sender);                //Better than throw - deprecated to 'require'
        _;                                           //executes check BEFORE func in this case
    }
    
    modifier nonOwnerFunc {
        require(owner != msg.sender);                //Better than throw - deprecated to 'require'
        _;                                           //executes check BEFORE func in this case
    }
      
}

contract Item is Owned {
    string private name;
    string private desc;
    uint private createdDateTime;
    uint private leasedDateTime;       
    uint private value;
    bool private isAvailable;
    address private leasee;
    //uint private timeSinceRentCollected;
    
    modifier leaseeFunc {
        require(leasee == msg.sender);              //Better than throw - deprecated to 'require'
        _;                                          //executes check BEFORE func in this case
    }    
    
    //Constructor
    constructor (string name_, string desc_, uint value_) public {
        name = name_;
        desc = desc_;
        createdDateTime = block.timestamp;
        value = value_;
        isAvailable = true;
    }
    
    //Lease requires a payment to the Item/contract address, part goes to owner as rent while the rest remains in contract
    function lease() public payable nonOwnerFunc {   
        require(isAvailable && msg.value == value);           //Item must be available to be leased
            leasee = msg.sender;                            //leasee will be set to sender of funds
            owner.transfer(msg.value/4);           //Send owner 1/4 of value as rent - keep rest in contract address
            isAvailable = false;
            leasedDateTime = block.timestamp;
    }
    
    //Only owner can verify the Item has been returned - remaining balance will be paid back to leasee
    function returnItem() public ownerFunc {
        require(isAvailable == false);               //Can't return an non leased item
        if (address(this).balance > 0) { leasee.transfer(address(this).balance); }
        leasee = 0;                                         //Clear leasee address - no longer leasee
        isAvailable = true;
        leasedDateTime = 0;                                         //Reset leased timestamp
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
        require(isAvailable == false);
        address(owner).transfer(address(this).balance);              //Send funds to owner from Item wallet
        //claimItem
    }
    
    //If balance has been paid out to owner, renter can claim ownership of Item
    function claimItem() public leaseeFunc {
        require(address(this).balance == 0);
        owner = leasee;                                     //Renter now becomes the owner
    }

//Todo: transfer funds daily
//Todo: check balance and call claimItem after event
    
    //Only owner can set value for Item    
    function setName(string newName) public ownerFunc {
        name = newName;
    }
    
    function getName() view public returns (string) {
        return name;
    }
    
    //Current timestamp minus created timestamp
    function getAge() view public returns (uint) {
        return block.timestamp - createdDateTime;
    }
    
    //Current timestamp minus leased timstamp
    function getLeasedTime() view public returns (uint) {
        require(leasedDateTime > 0 && isAvailable == false);                            
        return block.timestamp - leasedDateTime;
    }
    
    //Only owner can set desc Item
    function setDesc(string desc_) public ownerFunc {
        desc = desc_;
    }
    
    function getDesc() view public returns (string) {
        return desc;
    }
    
    //Only owner can set value for Item
    function setValue(uint value_) public ownerFunc {
        require(isAvailable);                                 //Cannot change value while being rented 
        value = value_;
    }
    
    function getValue() view public returns (uint) {
        return value;
    }
    
    //Get is public
    function getLeasee() view public returns (address) {
        return leasee;
    }  
    
    //Set availablity can only be done by return of item or change in ownership
    
    //Get is public
    function getAvailability() view public returns (bool) {
        return isAvailable;
    }
    
    //Get is public
    function getOwner() view public returns (address) {
        return owner;
    }
    
    //Kill instance of contract or kill contract on blockchain?
    function kill() public ownerFunc {
        selfdestruct(owner);
    }
}