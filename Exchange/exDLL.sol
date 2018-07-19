pragma solidity ^0.4.24;

contract exDLL
{
    struct node
    { //buy_tail, buy_head, sell_tail, sell_head
        int price;
    	string sell_prev; //sorted
	    string sell_next;
	    string buy_prev; //sorted
	    string buy_next;

        string prev; 
        string next;
        string key;
        int amount;
        string token;
    }
    
    int public length = 0;
    int public slength = 0; //sell length
    int public blength = 0; //buy length
    int public cancelLength = 0;
    int public settleLength = 0;
    string public sell_head;
    string public sell_tail;
    string public buy_head;
    string public buy_tail;
    string public cancel_head;
    string public cancel_tail;
    string public settle_head;
    string public settle_tail;
    string public head;
    string public tail;

    mapping(string=>node) private objects;
    mapping(string=>node) private cancelled;
    mapping(string=>node) private settled;
    string constant nil = "";


    function insert(string key, int price, bool update) public returns (bool)
    {
        bytes memory sb = bytes(key);
        
        if(bytes(key).length == 0) // if empty key
        {
            return false;
        }
        
        /*
        if(bytes(objects[key].key).length != 0 && update == true)
        {
            //update
            objects[key].price = price;
            return true;
        }
        */
        
        else if(update == false && bytes(objects[key].key).length != 0)
        {
            return false;
        }

        if(length == 0)
        {
            node memory object;
            objects[key] = object;

            objects[key].price = price;
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
        node memory object1 = node(price, "", "", "", "", tail, "", key, 0, "");
        objects[key] = object1;
        string memory previndex;
        string memory nextindex; // placeholder

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
            string memory target = getTargetKey(price, true);
            if(bytes(target).length == 0) //if belongs at end
            {
                previndex = sell_tail;
                objects[key].sell_prev = previndex;
                objects[sell_tail].sell_next = key;
                sell_tail = key;
            }
            
            else if(keccak256(bytes(target)) == keccak256(bytes(sell_head))) //if belongs at front
            {
                nextindex = sell_head;
                objects[key].sell_next = nextindex;
                objects[sell_head].sell_prev = key;
                sell_head = key;
            }
            
            else
            {
                previndex = objects[target].sell_prev;
                nextindex = target;
                objects[key].sell_next = nextindex;
                objects[key].sell_prev = previndex;
                objects[previndex].sell_next = key;
                objects[nextindex].sell_prev = key;
            }
            
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
            string memory targetb = getTargetKey(price, false);
            if(bytes(targetb).length == 0) //if it is "" belongs at end
            {
                previndex = buy_tail;
                objects[key].buy_prev = previndex;
                objects[buy_tail].buy_next = key;
                buy_tail = key;
            }
            
            else if(keccak256(bytes(targetb)) == keccak256(bytes(buy_head))) //if belongs at front
            {
                nextindex = buy_head;
                objects[key].buy_next = nextindex;
                objects[buy_head].buy_prev = key;
                buy_head = key;
            }
            
            else
            {
                previndex = objects[targetb].buy_prev;
                nextindex = targetb;
                objects[key].buy_next = nextindex;
                objects[key].buy_prev = previndex;
                objects[previndex].buy_next = key;
                objects[nextindex].buy_prev = key;
            }
            
            blength++;
        }
        
        //by default push_back to end of order list 
        objects[tail].next = key;
        tail = key;

        length++;
        return true;
    }
    
    function getTargetKey(int price, bool sb) public view returns (string)
    {
        //returns the index one after where it belongs
        if(sb == true) // if sell list
        {
            string storage index = sell_head;
            
            while(bytes(index).length != 0)
            {
                if(price < objects[index].price) return index;
                index = objects[index].sell_next;
            }
            return ""; // return empty if it belongs at end
        }
        
        else // if buy list 
        {
            string storage indexb = buy_head;
            
            while(bytes(indexb).length != 0)
            {
                if(price <= objects[indexb].price) return indexb;
                indexb = objects[indexb].buy_next;
            }
            return ""; // return empty if it belongs at end
        }
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
    
    
    function cancel(string targetkey) public returns(bool)
    {
        node memory objectc = objects[targetkey];
        cancelled[targetkey] = objectc;

        if(cancelLength == 0)
        {
            cancel_head = targetkey;
            cancel_tail = targetkey;
        }
        
        else //standard push_back
        {
            cancelled[cancel_tail].next = targetkey;
            cancelled[targetkey].prev = cancel_tail;
            cancel_tail = targetkey;
        }
        
        remove(targetkey);
    }
    
    
    function settle(string targetkey) public returns (bool)
    {
        node memory objectset = objects[targetkey];
        settled[targetkey] = objectset;

        if(settleLength == 0)
        {
            settle_head = targetkey;
            settle_tail = targetkey;
        }
        
        else //standard push_back
        {
            settled[settle_tail].next = targetkey;
            settled[targetkey].prev = settle_tail;
            settle_tail = targetkey;
        }
        
        remove(targetkey);
    }
    
    

    function sizes() public view returns (int, int, int)
    {
        return (length, slength, blength);
    }

    function getEntry(string key) public view returns (string, int, string, string)
    {
        if(bytes(objects[key].key).length == 0) 
        {
            return;    
        }
        return (objects[key].key, objects[key].price, objects[key].prev, objects[key].next);
    }
    
    function getSellEntry(string key) public view returns (string, int, string, string)
    {
        if(bytes(objects[key].key).length == 0) 
        {
            return;    
        }
        return (objects[key].key, objects[key].price, objects[key].sell_prev, objects[key].sell_next);
    }
    
    function getBuyEntry(string key) public view returns (string, int, string, string)
    {
        if(bytes(objects[key].key).length == 0) 
        {
            return;    
        }
        return (objects[key].key, objects[key].price, objects[key].buy_prev, objects[key].buy_next);
    }
    
    function getSellHead() public view returns (string, int, string, string)
    {
        if(bytes(sell_head).length == 0)
        {
            return;    
        }
        return (objects[sell_head].key, objects[sell_head].price, objects[sell_head].sell_prev, objects[sell_head].sell_next);
    }
    
    function getSellTail() public view returns (string, int, string, string)
    {
        if(bytes(sell_tail).length == 0)
        {
            return;    
        }
        return (objects[sell_tail].key, objects[sell_tail].price, objects[sell_tail].sell_prev, objects[sell_tail].sell_next);
    }
    
    function getBuyHead() public view returns (string, int, string, string)
    {
        if(bytes(buy_head).length == 0)
        {
            return;    
        }
        return (objects[buy_head].key, objects[buy_head].price, objects[buy_head].buy_prev, objects[buy_head].buy_next);
    }
    
    function getBuyTail() public view returns (string, int, string, string)
    {
        if(bytes(buy_tail).length == 0)
        {
            return;    
        }
        return (objects[buy_tail].key, objects[buy_tail].price, objects[buy_tail].buy_prev, objects[buy_tail].buy_next);
    }
    
    
    function getMarketPrice() public view returns (int)
    {   //assume they are already multiplied by 10000
        int answer = (objects[buy_head].price + objects[sell_tail].price)/2;
        return answer;
    }
    
    function needSettle() public view returns (bool)
    {
        return (objects[sell_tail].price <= objects[buy_head].price);
    }
    
    /*
    function populate() public
    {
        insert("s1","1", false);
        insert("s2","2", false);
        insert("s3","3", false);
        insert("b1","1", false);
        insert("b2","2", false);
        insert("b3","3", false);
    }
    */
}



