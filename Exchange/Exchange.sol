pragma solidity ^0.4.9;

contract Exchange {    
    struct order {
        address account;
        bytes32 orderKey; 
        string giveCurrencyName;
        string getCurrencyName; 
        uint price; //for settle function changed from string to uint
        uint amount;
        bytes32 prev; 
        bytes32 next;
        bytes32 status_prev; //in different list depending on status
        bytes32 status_next;
        bool partially_filled; //if true, user cannot cancel the order
        bool cancelled; //consider the race condition of cancel operation
        bool settled;
    }

    uint public length = 0;
    uint public sell_length = 0;
    uint public buy_length = 0;
    uint public cancelled_length = 0;
    uint public settled_length = 0;
    uint public nonce = 1; 
    bytes32 public sell_head;
    bytes32 public sell_tail;
    bytes32 public buy_head;
    bytes32 public buy_tail;
    bytes32 public cancelled_head;
    bytes32 public cancelled_tail;
    bytes32 public settled_head; 
    bytes32 public settled_tail;
    bytes32 public head;
    bytes32 public tail;
    bytes32 constant nil = "";

    mapping(string => mapping(address=>uint256)) balance;
    mapping(bytes32=>order) orders; //mapping of orderkeys to order objects
    mapping (address => bytes32[]) accountOrders; //mapping of account address to orderKeys
    mapping (string => address) currencies; //mapping of token name to token address 

    function deposit(address account, string currencyName, uint amount)  public {
        if (amount > 0)
            balance[currencyName][account] += amount;  
    }

    function withdraw(address account, string currencyName, uint amount) public {
        if (balance[currencyName][account] >= amount)
            balance[currencyName][account] -= amount;  
    }

    function getBalance(address account, string currencyName) public view returns(uint) {
        return balance[currencyName][account];
    }

    function getOrderkey() public returns(bytes32 key) {
        key = keccak256(abi.encodePacked(nonce));
        nonce++;
        return key;
    }

    function createLimitOrder(
        address account, 
        bytes32 orderkey,
        string giveCurrencyName, //give currency fund should be checked 
        string getCurrencyName, 
        uint price,
        uint amount
    ) 
        public 
    { 
        insert(account, orderkey, giveCurrencyName, getCurrencyName, price, amount);
        
        //connect the account to the order 
        accountOrders[account].push(orderkey);
    }
    
    
    function createMarketOrder(
        address account,
        bytes32 orderkey,
        string giveCurrencyName,
        string getCurrencyName, 
        uint amount
    ) 
        public returns (bool)
    {
        if (balance[giveCurrencyName][account] < amount) {
            return false;
        }
        
        uint price = getMarketPrice(); 
        createLimitOrder(account, orderkey, giveCurrencyName, getCurrencyName, price, amount);
    }
    
    /*
    //implement after supporting multiple markets 
    function getMarketPrice(string giveCurrencyName, string getCurrencyName) public returns(uint marketPrice) {
        marketPrice = 0;
        return marketPrice;
    }
    */

    function getMarketPrice() public view returns(uint marketPrice) {
        //highest buy lowest sell average
        marketPrice = (orders[buy_tail].price + orders[sell_head].price)/2;
        return marketPrice;
    }

/*
    function settle() public returns(bool) {
        bytes32 buyOrderKey;
        bytes32 sellOrderKey;
        bytes32 prevBuyOrderKey;
        uint buyPrice;
        uint sellPrice;
        uint buyAmount;
        uint sellAmount;
        address buyAccount;
        address sellAccount;

        for (buyOrderKey = buy_head;
            buyOrderKey.length != 0;
            buyOrderKey = orders[buyOrderKey].status_next) {
            
            prevBuyOrderKey = orders[buyOrderKey].status_prev;
            if (orders[prevBuyOrderKey].amount == 0) { //move the previous buy order to settled list if the order is completely filled up
                putSettle(prevBuyOrderKey);
            }

            buyPrice = orders[buyOrderKey].price;
            buyAmount = orders[buyOrderKey].amount;
            buyAccount = orders[buyOrderKey].account;

            for(sellOrderKey = sell_head;
                sellOrderKey.length != 0;
                sellOrderKey = orders[sellOrderKey].status_next) {
                
                sellPrice = orders[sellOrderKey].price;
                sellAmount = orders[sellOrderKey].amount;
                sellAccount = orders[buyOrderKey].account;

                if (buyPrice >= sellPrice) { //condition for successful trade to happen
                    //amount represents the amount of getCurrency to trade 
                    //price represents the amount of giveCurrency per 1 getCurrency 

                    //if partially filled, partially filled flag gets marked true 
                    //partially filled orders cannot be canceled. cancel order process must happen after ensuring that the partially processed is not 
                    if (buyAmount > sellAmount) { //buyAmount partially filled
                        deposit(buyAccount, "BitCoin", sellAmount); //change later to support multiple markes - bitcoin market, USD market, Ether Market, LTC Market 
                        withdraw(buyAccount, "USD", sellAmount * buyPrice);
                        deposit(sellAccount, "USD", sellAmount * buyPrice);
                        withdraw(sellAccount, "BitCoin", sellAmount);
                        buyAmount -= sellAmount; //potentially not changing data in the hash table 
                        sellAmount = 0;
                        orders[buyOrderKey].partially_filled = true;
                    } else if (sellAmount > buyAmount) { //sellAmount partially filled 
                        deposit(buyAccount, "BitCoin", buyAmount);
                        withdraw(buyAccount, "USD", buyAmount * buyPrice);
                        deposit(sellAccount, "USD", buyAmount * buyPrice);
                        withdraw(sellAccount, "BitCoin", buyAmount);
                        sellAmount -= buyAmount;
                        buyAmount = 0;
                        orders[sellOrderKey].partially_filled = true;
                    } else if (sellAmount == buyAmount) { //both buy and sell completely filled 
                        deposit(buyAccount, "BitCoin", buyAmount);
                        withdraw(buyAccount, "USD", buyAmount * buyPrice);
                        deposit(sellAccount, "USD", buyAmount * buyPrice);
                        withdraw(sellAccount, "BitCoin", buyAmount);
                        sellAmount = 0;
                        buyAmount = 0;
                    }
                    if (buyAmount == 0) {  
                        break;
                    } else if (sellAmount == 0) {
                        remove(sellOrderKey);
                        putSettle(sellOrderKey);
                        continue;
                    }
                }                
            }
        }
        return true;
    }
*/
    function insert(
        address account,
        bytes32 orderKey,
        string giveCurr,
        string getCurr,
        uint price,  
        uint amount
    )
    public returns (bool)
    {
                        
        if(orderKey.length == 0) {
            return false; 
        }

        //instantiate
        order memory ord; 
        orders[orderKey] = ord;
        orders[orderKey].orderKey = orderKey;
        orders[orderKey].account = account;
        orders[orderKey].giveCurrencyName = giveCurr;
        orders[orderKey].getCurrencyName = getCurr;
        orders[orderKey].price = price;
        orders[orderKey].amount = amount; 
        
        if(length == 0) {
            
            head = orderKey;
            tail = orderKey;

            if(keccak256(bytes(giveCurr)) == keccak256("USD")) {
                buy_head = orderKey;
                buy_tail = orderKey;
                buy_length++;
            }
            else if(keccak256(bytes(giveCurr)) == keccak256("BitCoin")) {
                sell_head = orderKey;
                sell_tail = orderKey;
                sell_length++;
            }
            length++;
            return true; 
        }
        
        bytes32 previndex;
        bytes32 nextindex;
        
        //cannot just put in previous if statement as it can't set the head that is not the first
        if(keccak256(bytes(giveCurr)) == keccak256("USD") && buy_length == 0) {
            buy_head = orderKey; 
            buy_tail = orderKey; 
            buy_length++;
        }
        
        //regular case where sell_length > 0
        else if(keccak256(bytes(giveCurr)) == keccak256("USD")) { 
            bytes32 targetbuy = getTargetKey(price, 0);
            if(targetbuy == "") {
                //if it is "" belongs at end
                previndex = buy_tail;
                orders[orderKey].status_prev = previndex;
                orders[buy_tail].status_next = orderKey;
                buy_tail = orderKey;
            }
            
            else if(targetbuy == buy_head) {
                
                //if belongs at front
                nextindex = buy_head;
                orders[orderKey].status_next = nextindex;
                orders[buy_head].status_prev = orderKey;
                buy_head = orderKey;
            }
            
            else {
                previndex = orders[targetbuy].status_prev;
                nextindex = targetbuy;
                orders[orderKey].status_next = nextindex;
                orders[orderKey].status_prev = previndex;
                orders[previndex].status_next = orderKey;
                orders[nextindex].status_prev = orderKey;
            }
        
            buy_length++;
        }
        
        if(keccak256(bytes(giveCurr)) == keccak256("BitCoin") && sell_length == 0) {
            sell_head = orderKey; 
            sell_tail = orderKey; 
            sell_length++;
        }
        
        //regular case where sell_length > 0
        else if(keccak256(bytes(giveCurr)) == keccak256("BitCoin")) {
            bytes32 target = getTargetKey(price, 1);
            if(target == "") {
                //if belongs at end 
                previndex = sell_tail;
                orders[orderKey].status_prev = previndex;
                orders[sell_tail].status_next = orderKey;
                sell_tail = orderKey;
            }
            
            else if(target == sell_head) {
                //if belongs at front
                nextindex = sell_head;
                orders[orderKey].status_next = nextindex;
                orders[sell_head].status_prev = orderKey;
                sell_head = orderKey;
            }
            
            else {
                previndex = orders[target].status_prev;
                nextindex = target;
                orders[orderKey].status_next = nextindex;
                orders[orderKey].status_prev = previndex;
                orders[previndex].status_next = orderKey;
                orders[nextindex].status_prev = orderKey;
            }

            sell_length++;
        }
        
        //by default push_back to end of order list 
        orders[tail].next = orderKey;
        orders[orderKey].prev = tail;
        tail = orderKey;

        length++;
    }
    
    function getTargetKey(uint256 price, int giveCurrency) public view returns (bytes32) 
    {
        //returns index after it, nil if at end
        //giveCurrency is 0 if USD, 1 if BitCoin, ... etc
        
        bytes32 targetkey;
        
        if(giveCurrency == 0) { //for buy
            targetkey = buy_head;
            while(targetkey != "" && price >= orders[targetkey].price) {
                targetkey = orders[targetkey].status_next;
            }
        }
        
        else if(giveCurrency == 1) { //for sell
            targetkey = sell_head;
            while(targetkey != "" && price > orders[targetkey].price) {
                targetkey = orders[targetkey].status_next;
            }
        }
        
        return targetkey;
    }
    
    function cancel(bytes32 targetkey) public { //consider race condition
        
        //to make sure that a targetkey can only be cancelled from the buy/sell lists
        if(orders[targetkey].cancelled != true && orders[targetkey].settled != true 
          && orders[targetkey].partially_filled == false)
        {
            remove(targetkey);
            if (cancelled_length == 0) {
                cancelled_head = targetkey;
                cancelled_tail = targetkey;
                cancelled_length++;
            } else {
                orders[cancelled_tail].status_next = targetkey;
                orders[targetkey].status_prev = cancelled_tail;
                cancelled_tail = targetkey;
                cancelled_length++; 
            }
            
            orders[targetkey].cancelled = true;
        }
    }

    function putSettle(bytes32 targetkey) public { //consider race condition
        
        //to make sure that a targetkey can only be cancelled from the buy/sell lists
        if(orders[targetkey].cancelled != true && orders[targetkey].settled != true)
        {
            remove(targetkey);
            if (settled_length == 0) {
                settled_head = targetkey;
                settled_tail = targetkey;
                settled_length++;
            } else {
                orders[settled_tail].status_next = targetkey;
                orders[targetkey].status_prev = settled_tail;
                settled_tail = targetkey;
                settled_length++; 
            }
            
            orders[targetkey].partially_filled = false;
            orders[targetkey].settled = true;
        }
    }

    function remove(bytes32 targetkey) public returns (bool) { //does not destroy the object, just takes it out of the buy and sell order list 
        if(orders[targetkey].orderKey.length == 0 || length == 0) {
            //if the key value is nonexistent or if list is empty
            return false;
        }
        
        //for buy list
        if(keccak256(bytes(orders[targetkey].giveCurrencyName)) == keccak256("USD")) { 
            //Question-why is bytes used on the left side and not on the right side?  
            if(targetkey == buy_head) {
                buy_head = orders[buy_head].status_next;
                orders[buy_head].status_prev = nil;
            } else if(targetkey == buy_tail) {
                buy_tail = orders[buy_tail].status_prev;
                orders[buy_tail].status_next = nil;
            } else {
                bytes32 bprevkey = orders[targetkey].status_prev;
                bytes32 bnextkey = orders[targetkey].status_next;
                orders[bprevkey].status_next = bnextkey;
                orders[bnextkey].status_prev = bprevkey;
            }
            buy_length--;
        }
        
        //for sell list
        if(keccak256(bytes(orders[targetkey].giveCurrencyName)) == keccak256("BitCoin")) { 
            if(targetkey == sell_head) {
                sell_head = orders[sell_head].status_next;
                orders[sell_head].status_prev = nil;
            } else if(targetkey == sell_tail) {
                sell_tail = orders[sell_tail].status_prev;
                orders[sell_tail].status_next = nil;
            } else {
                bytes32 sprevkey = orders[targetkey].status_prev;
                bytes32 snextkey = orders[targetkey].status_next;
                orders[sprevkey].status_next = snextkey;
                orders[snextkey].status_prev = sprevkey;
            }
            sell_length--;
        }
    }

    function sizes() public view returns (uint, uint, uint, uint, uint) {
        return (length, sell_length, buy_length, cancelled_length, settled_length);
    }

    function getPrev(bytes32 orderKey) public view returns (bytes32) {
        return orders[orderKey].status_prev;
    }

    function getNext(bytes32 orderKey) public view returns (bytes32) {
        return orders[orderKey].status_next;
    }

    function getPrice(bytes32 orderKey) public view returns (uint) {
        return orders[orderKey].price;
    }

    function getAmount(bytes32 orderKey) public view returns (uint) {
        return orders[orderKey].amount;
    }

    function getAccount(bytes32 orderKey) public view returns (address) {
        return orders[orderKey].account;
    }

    function setAmount(bytes32 orderKey, uint newAmount) public returns (bool) {
        orders[orderKey].amount = newAmount; 
        return true;
    }

    function partiallyFilled(bytes32 orderKey) public returns(bool) { 
        orders[orderKey].partially_filled = true; 
        return true;
    }

    function getOrderInfo(bytes32 orderKey) public returns(address, bytes32, string, string, uint, uint, string) {
        string memory status; 
        if (orders[orderKey].cancelled)
            status = "Cancelled";
        else if (orders[orderKey].settled)
            status = "Settled";
        else if (orders[orderKey].partially_filled)
            status = "Partially filled";
        else
            status = "Open"; 
        
        return (orders[orderKey].account, orders[orderKey].orderKey, orders[orderKey].giveCurrencyName, orders[orderKey].getCurrencyName, orders[orderKey].amount, orders[orderKey].price, status);
    }
}
