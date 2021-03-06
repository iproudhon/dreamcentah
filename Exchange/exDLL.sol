pragma solidity ^0.4.24;

contract exDLL {

    struct order {
        address account;
        bytes32 orderKey; 
        string giveCurrencyName;
        string getCurrencyName; 
        string price; 
        string amount;
        bytes32 prev; 
        bytes32 next;
        bytes32 status_prev; //in different list depending on status
        bytes32 status_next;
        bool cancelled;
        bool settled;
    }

    uint public length = 0;
    uint public sell_length = 0;
    uint public buy_length = 0;
    uint public cancelled_length = 0;
    uint public settled_length = 0;
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

    mapping(bytes32=>order) private orders; //mapping of orderkeys to order objects
    
    function insert(bytes32 orderKey, string giveCurr, string getCurr,
                    string price, address account, string amount) public returns (bool) {
                        
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
        
        //cannot just put in previous if statement as it can't set the head that is not the first
        if(keccak256(bytes(giveCurr)) == keccak256("USD") && buy_length == 0) {
            buy_head = orderKey; 
            buy_tail = orderKey; 
            buy_length++;
        }
        //regular case where sell_length > 0
        else if(keccak256(bytes(giveCurr)) == keccak256("USD")) { 
            orders[orderKey].status_prev = buy_tail; 
            orders[buy_tail].status_next = orderKey; 
            buy_tail = orderKey; 
            buy_length++;
        }
        
        if(keccak256(bytes(giveCurr)) == keccak256("BitCoin") && sell_length == 0) {
            sell_head = orderKey; 
            sell_tail = orderKey; 
            sell_length++;
        }
        //regular case where sell_length > 0
        else if(keccak256(bytes(giveCurr)) == keccak256("BitCoin")) { // if it is s sell at the start of string
            orders[orderKey].status_prev = sell_tail; 
            orders[sell_tail].status_next = orderKey; 
            sell_tail = orderKey; 
            sell_length++;
        }
        
        //by default push_back to end of order list 
        orders[tail].next = orderKey;
        tail = orderKey;

        length++;
    }
    
    function cancel(bytes32 targetkey) public {
        
        //to make sure that a targetkey can only be cancelled from the buy/sell lists
        if(orders[targetkey].cancelled != true && orders[targetkey].settled != true)
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

    function remove(bytes32 targetkey) public returns (bool) { //does not destroy the object, just takes it out of the buy and sell order list 
        if(orders[targetkey].orderKey.length == 0 || length == 0) {
            //if the key value is nonexistent or if list is empty
            return false;
        }
        
        //for buy list
        if(keccak256(bytes(orders[targetkey].giveCurrencyName)) == keccak256("USD")) {
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

    function getEntry(bytes32 orderKey) public view returns (bytes32, string, bytes32, bytes32) {
        if(orders[orderKey].orderKey.length == 0) 
            return;    
        
        //key, value, prev, next, status_prev, status_next, status_prev, status_next
        return (orders[orderKey].orderKey, orders[orderKey].price, orders[orderKey].prev, orders[orderKey].next);
    }
    
    function getStatusEntry(bytes32 orderKey) public view returns (bytes32, string, bytes32, bytes32) {
        if(orders[orderKey].orderKey.length == 0) 
            return;    
        
        //key, value, prev, next, status_prev, status_next, status_prev, status_next
        return (orders[orderKey].orderKey, orders[orderKey].price, orders[orderKey].status_prev, orders[orderKey].status_next);
    }

    
    function getSellHead() public view returns (bytes32, string, bytes32, bytes32) {
        if(sell_head.length == 0)
            return;    
        
        return (orders[sell_head].orderKey, orders[sell_head].price, orders[sell_head].status_prev, orders[sell_head].status_next);
    }
    
    function getSellTail() public view returns (bytes32, string, bytes32, bytes32) {
        if(sell_tail.length == 0)
            return;    
        
        return (orders[sell_tail].orderKey, orders[sell_tail].price, orders[sell_tail].status_prev, orders[sell_tail].status_next);
    }
    
    function getBuyHead() public view returns (bytes32, string, bytes32, bytes32) {
        if(buy_head.length == 0) 
            return;    
        
        return (orders[buy_head].orderKey, orders[buy_head].price, orders[buy_head].status_prev, orders[buy_head].status_next);
    }
    
    function getBuyTail() public view returns (bytes32, string, bytes32, bytes32) {
        if(buy_tail.length == 0)
            return;    
        
        return (orders[buy_tail].orderKey, orders[buy_tail].price, orders[buy_tail].status_prev, orders[buy_tail].status_next);
    }
    
    function testpopulate() public
    {
        insert(0x1, "USD", "BitCoin", "1", 0x0, "0"); //buy
        insert(0x2, "USD", "BitCoin", "2", 0x0, "0");
        insert(0x3, "USD", "BitCoin", "3", 0x0, "0");
        insert(0x4,"BitCoin","USD", "4", 0x0, "0"); //sell
        insert(0x5,"BitCoin","USD", "5", 0x0, "0");
        insert(0x6,"BitCoin","USD", "6", 0x0, "0");
    }
}
