pragma solidity ^0.4.24;
//style change 
//node change the name to order 
//order needs to cointain info
//
contract exDLL {
    struct order {
        
        bytes32 OrderKey; 
        address account;
        string giveCurrencyName;
        string getCurrencyName; 
        string price; 
        string amount;
        bytes32 prev; 
        bytes32 next;
        bytes32 status_prev; //in different list depending on status
        bytes32 status_next; 
    }

    uint public length = 0;
    uint public slength = 0;
    uint public blength = 0;
    bytes32 public sell_head;
    bytes32 public sell_tail;
    bytes32 public buy_head;
    bytes32 public buy_tail;
    bytes32 public head;
    bytes32 public tail;

    mapping(string=>order) private orders;
    string constant nil = "";

    function insert(
        bytes32 orderKey,
        address account,
        string _giveCurrencyName,
        string _getcurrencyName,
        string _price,
        string _amount
    )
        public 
    {
        if(orderKey.length == 0)
            return false; 

        order memory _order; 
        orders[orderKey] = _order;
        orders[orderKey].giveCurrencyName = _giveCurrencyName;
        orders[orderKey].getCurrencyName = _getcurrencyName;
        orders[orderKey].price = _price;
        orders[orderKey].amount = _amount; 
        head = orderKey; 
        tail = orderKey;
        
        if(length == 0) {
            
            head = orderKey;
            tail = orderKey;

            if(_giveCurrencyName == "USD") {
                buy_head = orderKey;
                buy_tail = orderKey;
                blength++;
            }
            else if(_giveCurrencyName == "BitCoin") {
                sell_head = orderKey;
                sell_tail = orderKey;
                slength++;
            }
            length++;
            return true; 
        }
        
        //cannot just put in previous if statement as it can't set the head that is not the first
        if(_giveCurrencyName == "USD" && blength == 0) {
            buy_head = orderKey; 
            buy_tail = orderKey; 
            blength++;
        }
        //regular case where slength > 0
        else if(_giveCurrencyName == "USD") { // if it is s sell at the start of string
            orders[orderKey].status_prev = buy_tail; 
            orders[buy_tail].status_next = orderKey; 
            buy_tail = orderKey; 
            blength++;
        }
            
        //cannot just put in previous if statement as it can't set the head that is not the first
        if(_giveCurrencyName == "BitCoin" && slength == 0) {
            sell_head = orderKey; 
            sell_tail = orderKey; 
            slength++;
        }
        //regular case where slength > 0
        else if(_giveCurrencyName == "BitCoin") { // if it is s sell at the start of string
            orders[orderKey].status_prev = sell_tail; 
            orders[sell_tail].status_next = orderKey; 
            sell_tail = orderKey; 
            slength++;
        }
        
        //by default push_back to end of order list 
        orders[tail].next = orderKey;
        tail = orderKey;

        length++;
    }

    function remove(string targetkey) public returns (bool) {
        bytes memory sb = bytes(targetkey);
        
        if(bytes(objects[targetkey].key).length == 0 || length == 0) {
            //if the key value is nonexistent or if list is empty
            return false;
        }

        if(length == 1) {
            delete objects[targetkey];
            length--;
            slength = 0;
            blength = 0;
            head = nil;
            tail = nil;
            sell_head = nil;
            sell_tail = nil;
            buy_head = nil;
            buy_tail = nil;
            return true;
        }
        
        //for sell list
        if(keccak256(bytes(targetkey)) == keccak256(bytes(sell_head))) {
            sell_head = objects[sell_head].sell_next;
            objects[sell_head].sell_prev = nil;
        }
        else if(keccak256(bytes(targetkey)) == keccak256(bytes(sell_tail))) {
            sell_tail = objects[sell_tail].sell_prev;
            objects[sell_tail].sell_next = nil;
        }
        else {
            string storage sprevkey = objects[targetkey].sell_prev;
            string storage snextkey = objects[targetkey].sell_next;
            objects[sprevkey].sell_next = snextkey;
            objects[snextkey].sell_prev = sprevkey;
        }
        
        //for buy list
        if(keccak256(bytes(targetkey)) == keccak256(bytes(buy_head))) {
            buy_head = objects[buy_head].buy_next;
            objects[buy_head].buy_prev = nil;
        }
        else if(keccak256(bytes(targetkey)) == keccak256(bytes(buy_tail))) {
            buy_tail = objects[buy_tail].buy_prev;
            objects[buy_tail].buy_next = nil;
        }
        else {
            string storage bprevkey = objects[targetkey].buy_prev;
            string storage bnextkey = objects[targetkey].buy_next;
            objects[bprevkey].buy_next = bnextkey;
            objects[bnextkey].buy_prev = bprevkey;
        }

        //all orders list
        if(keccak256(bytes(targetkey)) == keccak256(bytes(head))) {
            head = objects[targetkey].next;
            objects[head].prev = nil;
        }
        else if(keccak256(bytes(targetkey)) == keccak256(bytes(tail))) {
            tail = objects[targetkey].prev;
            objects[tail].next = nil;
        }
        else { //if the entry is at neither the head or the tail of the list, at least 3 entries
    
            string storage prevkey = objects[targetkey].prev;
            string storage nextkey = objects[targetkey].next;
            objects[prevkey].next = nextkey;
            objects[nextkey].prev = prevkey;
        }

        if(sb[0] == 115) // if it is "s" sell at the start of string
            slength--;
          
        else if(sb[0] == 98) // if it is "b" buy at the start of string
            blength--;
    
        //delete objects[targetkey];
        length--;
    }

    function cancel(string targetkey) public {
        bytes memory sb = bytes(targetkey);
        remove(targetkey);
        if(sb[0] == 115) // if it is "s" sell at the start of string
            slength--; 
        
            
        else if(sb[0] == 98) // if it is "b" buy at the start of string
            blength--;
        
    }

    function sizes() public view returns (int, int, int) {
        return (length, slength, blength);
    }

    function getEntry(string key) public view returns (string, string, string, string) {
        if(bytes(objects[key].key).length == 0) 
            return;    
        
        //key, value, prev, next, sell_prev, sell_next, buy_prev, buy_next
        return (objects[key].key, objects[key].value, objects[key].prev, objects[key].next);
    }
    
    function getSellEntry(string key) public view returns (string, string, string, string) {
        if(bytes(objects[key].key).length == 0) 
            return;    
        
        //key, value, prev, next, sell_prev, sell_next, buy_prev, buy_next
        return (objects[key].key, objects[key].value, objects[key].sell_prev, objects[key].sell_next);
    }
    
    function getBuyEntry(string key) public view returns (string, string, string, string) {
        if(bytes(objects[key].key).length == 0) 
            return;    
        
        //key, value, prev, next, sell_prev, sell_next, buy_prev, buy_next
        return (objects[key].key, objects[key].value, objects[key].buy_prev, objects[key].buy_next);
    }
    
    function getSellHead() public view returns (string, string, string, string) {
        if(bytes(sell_head).length == 0)
            return;    
        
        return (objects[sell_head].key, objects[sell_head].value, objects[sell_head].sell_prev, objects[sell_head].sell_next);
    }
    
    function getSellTail() public view returns (string, string, string, string) {
        if(bytes(sell_tail).length == 0)
            return;    
        
        return (objects[sell_tail].key, objects[sell_tail].value, objects[sell_tail].sell_prev, objects[sell_tail].sell_next);
    }
    
    function getBuyHead() public view returns (string, string, string, string) {
        if(bytes(buy_head).length == 0) 
            return;    
        
        return (objects[buy_head].key, objects[buy_head].value, objects[buy_head].buy_prev, objects[buy_head].buy_next);
    }
    
    function getBuyTail() public view returns (string, string, string, string) {
        if(bytes(buy_tail).length == 0)
            return;    
        
        return (objects[buy_tail].key, objects[buy_tail].value, objects[buy_tail].buy_prev, objects[buy_tail].buy_next);
    }
    
}



