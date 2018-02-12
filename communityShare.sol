pragma solidity ^0.4.0;

contract Item {
    address private owner;
    address private leasee;
    string private name;
    string private desc;
    uint private created;
    uint private leased;       
    uint private value;
    bool private available;
    uint private balance;
    
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
    function Item (string name_, string desc_, uint value_) public {
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
        require(available == true);                         //Item must be available to be leased
        require(msg.value >= value);
        if(msg.value >= value) {
            leasee = msg.sender;                            //leasee will be set to sender of funds
            address(owner).send(msg.value/4);               //Send owner 1/4 of value as rent - keep rest in contract address
            available = false;
            leased = block.timestamp;
        } else { return; }
    }
    
    //Only owner can verify the Item has been returned - remaining balance will be paid back to leasee
    function returnItem() public ownerFunc {
        require(available == false);                        //Can't return an un leased item
        if(this.balance > 0) { address(leasee).send(this.balance); }
        leasee = 0;                                         //Clear leasee address - no longer leasee
        available = true;
        leased = 0;                                         //Reset leased timestamp
    }
    
    //(Only) Leasee can pay towards balance - can trigger claim of ownership
    function payOut() public leaseeFunc  {
        require(available == false);
        address(owner).send(getBalance());                  //Send funds to owner from Item wallet
        //claimItem;
    }
    
    //If balance has been paid out to owner, renter can claim ownership of Item
    function claimItem() public leaseeFunc {
        require(this.balance == 0);
        if(this.balance == 0) { owner = leasee; }            //Renter now becomes the owner
    }

//Todo: transfer funds daily
//Todo: check balance and call claimItem after event
    
    //Only owner can set value for Item    
    function setName(string newName) ownerFunc {
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
        require(leased > 0 && available == false);                            
        return block.timestamp - leased;
    }
    
    //Only owner can set value for Item
    function setDesc(string desc_) ownerFunc {
        desc = desc_;
    }
    
    function getDesc() returns (string) {
        return desc;
    }
    
    //Only owner can set value for Item
    function setValue(uint value_) ownerFunc {
        value = value_;
    }
    
    function getValue() returns (uint) {
        return value;
    }
    
    //Only owner can set leseeAddress for Item
    function setLeasee(address leaseeAddr_) ownerFunc {
        leasee = leaseeAddr_;
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
        return this.balance;
    }   
    
    //Kill instance of contract or kill contract on blockchain?
    function kill() ownerFunc {
        selfdestruct(owner);
    }
}