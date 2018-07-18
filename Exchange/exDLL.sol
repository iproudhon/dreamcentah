pragma solidity ^0.4.24;

contract exDLL
{
    struct node
    {
        string value;
    	string sell_prev;
	    string sell_next;
	    string buy_prev;
	    string buy_next;
        string prev;
        string next;
        string key;
    }

    int public length = 0;
    int public slength = 0;
    int public blength = 0;
    string public sell_head;
    string public sell_tail;
    string public buy_head;
    string public buy_tail;
    string public head;
    string public tail;

    mapping(string=>node) private objects;
    string constant nil = "";


    function insert(string key, string value, bool update) public returns (bool)
    {
        bytes memory sb = bytes(key);
        
        if(bytes(key).length == 0) // if empty key
        {
            return false;
        }
        
        if(bytes(objects[key].key).length != 0 && update == true)
        {
            //update
            objects[key].value = value;
            return true;
        }
        
        else if(update == false && bytes(objects[key].key).length != 0)
        {
            return false;
        }

        if(length == 0)
        {
            node memory object;
            objects[key] = object;

            objects[key].value = value;
            objects[key].key = key;
            //rest are nil ""
            
            head = key;
            tail = key;
            
            if(sb[0] == 115) {
                sell_head = key;
                sell_tail = key;
                slength++;
            }
            if(sb[0] == 98) {
                buy_head = key;
                buy_tail = key;
                blength++;
            }
            
            length++;
            return true;
        }
        
        //instantiate the node
        node memory object1 = node(value, "", "", "", "", tail, "", key);
        objects[key] = object1;
        string memory previndex; // placeholder

        //cannot just put in previous if statement as it can't set the head that is not the first
        if(sb[0] == 115 && slength == 0)
        {
            sell_head = key;
            sell_tail = key;
            slength++;
        }
        //regular case where slength > 0
        else if(sb[0] == 115) // if it is "s" sell at the start of string
        {
            previndex = sell_tail;
            objects[key].sell_prev = previndex;
            objects[sell_tail].sell_next = key;
            sell_tail = key;
            slength++;
        }
            
        if(sb[0] == 98 && blength == 0)
        {
            buy_head = key;
            buy_tail = key;
            blength++;
        }
        
        else if(sb[0] == 98) // if it is "b" buy at the start of string
        {
            previndex = buy_tail;
            objects[key].buy_prev = previndex;
            objects[buy_tail].buy_next = key;
            buy_tail = key;
            blength++;
        }
        
        //by default push_back to end of order list 
        objects[tail].next = key;
        tail = key;

        length++;
        return true;
    }

    function remove(string targetkey) public returns (bool)
    {
        bytes memory sb = bytes(targetkey);
        
        if(bytes(objects[targetkey].key).length == 0 || length == 0)
        {
            //if the key value is nonexistent or if list is empty
            return false;
        }

        if(length == 1)
        {
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
        if(keccak256(bytes(targetkey)) == keccak256(bytes(sell_head)))
        {
            sell_head = objects[sell_head].sell_next;
            objects[sell_head].sell_prev = nil;
        }
        
        else if(keccak256(bytes(targetkey)) == keccak256(bytes(sell_tail)))
        {
            sell_tail = objects[sell_tail].sell_prev;
            objects[sell_tail].sell_next = nil;
        }
        
        else
        {
            string storage sprevkey = objects[targetkey].sell_prev;
            string storage snextkey = objects[targetkey].sell_next;
            objects[sprevkey].sell_next = snextkey;
            objects[snextkey].sell_prev = sprevkey;
        }
        
        //for buy list
        if(keccak256(bytes(targetkey)) == keccak256(bytes(buy_head)))
        {
            buy_head = objects[buy_head].buy_next;
            objects[buy_head].buy_prev = nil;
        }
        
        else if(keccak256(bytes(targetkey)) == keccak256(bytes(buy_tail)))
        {
            buy_tail = objects[buy_tail].buy_prev;
            objects[buy_tail].buy_next = nil;
        }
        
        else
        {
            string storage bprevkey = objects[targetkey].buy_prev;
            string storage bnextkey = objects[targetkey].buy_next;
            objects[bprevkey].buy_next = bnextkey;
            objects[bnextkey].buy_prev = bprevkey;
        }

        //all orders list
        if(keccak256(bytes(targetkey)) == keccak256(bytes(head)))
        {
            head = objects[targetkey].next;
            objects[head].prev = nil;
        }

        else if(keccak256(bytes(targetkey)) == keccak256(bytes(tail)))
        {
            tail = objects[targetkey].prev;
            objects[tail].next = nil;
        }

        else //if the entry is at neither the head or the tail of the list, at least 3 entries
        {
            string storage prevkey = objects[targetkey].prev;
            string storage nextkey = objects[targetkey].next;
            objects[prevkey].next = nextkey;
            objects[nextkey].prev = prevkey;
        }


        if(sb[0] == 115) // if it is "s" sell at the start of string
        {
            slength--;
        }
            
        else if(sb[0] == 98) // if it is "b" buy at the start of string
        {
            blength--;
        }
        delete objects[targetkey];
        length--;
    }

    function sizes() public view returns (int, int, int)
    {
        return (length, slength, blength);
    }

    function getEntry(string key) public view returns (string, string, string, string)
    {
        if(bytes(objects[key].key).length == 0) 
        {
            return;    
        }
        //key, value, prev, next, sell_prev, sell_next, buy_prev, buy_next
        return (objects[key].key, objects[key].value, objects[key].prev, objects[key].next);
    }
    
    function getSellEntry(string key) public view returns (string, string, string, string)
    {
        if(bytes(objects[key].key).length == 0) 
        {
            return;    
        }
        //key, value, prev, next, sell_prev, sell_next, buy_prev, buy_next
        return (objects[key].key, objects[key].value, objects[key].sell_prev, objects[key].sell_next);
    }
    
    function getBuyEntry(string key) public view returns (string, string, string, string)
    {
        if(bytes(objects[key].key).length == 0) 
        {
            return;    
        }
        //key, value, prev, next, sell_prev, sell_next, buy_prev, buy_next
        return (objects[key].key, objects[key].value, objects[key].buy_prev, objects[key].buy_next);
    }
    
    function getSellHead() public view returns (string, string, string, string)
    {
        if(bytes(sell_head).length == 0)
        {
            return;    
        }
        return (objects[sell_head].key, objects[sell_head].value, objects[sell_head].sell_prev, objects[sell_head].sell_next);
    }
    
    function getSellTail() public view returns (string, string, string, string)
    {
        if(bytes(sell_tail).length == 0)
        {
            return;    
        }
        return (objects[sell_tail].key, objects[sell_tail].value, objects[sell_tail].sell_prev, objects[sell_tail].sell_next);
    }
    
    function getBuyHead() public view returns (string, string, string, string)
    {
        if(bytes(buy_head).length == 0)
        {
            return;    
        }
        return (objects[buy_head].key, objects[buy_head].value, objects[buy_head].buy_prev, objects[buy_head].buy_next);
    }
    
    function getBuyTail() public view returns (string, string, string, string)
    {
        if(bytes(buy_tail).length == 0)
        {
            return;    
        }
        return (objects[buy_tail].key, objects[buy_tail].value, objects[buy_tail].buy_prev, objects[buy_tail].buy_next);
    }
    
    function populate() public
    {
        insert("s1","1", false);
        insert("s2","2", false);
        insert("s3","3", false);
        insert("b1","1", false);
        insert("b2","2", false);
        insert("b3","3", false);
    }
}



