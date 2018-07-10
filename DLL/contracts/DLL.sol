pragma solidity ^0.4.24;

contract DLL
{
    struct node
    {
        string value;
    	string sorted_prev;
	    string sorted_next;
        string prev;
        string next;
        string key;
    }

    int public length = 0;
    string public sorted_head;
    string public sorted_tail;
    string public head;
    string public tail;

    mapping(string=>node) private objects;
    string constant nil = "";

    function insert(string key, string value, string targetkey, bool update) public returns (bool)
    {
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
            
            object.value = value;
            object.key = key;
            //rest are nil ""
            
            objects[key] = object;
            head = key;
            tail = key;
            sorted_head = key;
            sorted_tail = key;
            length++;
            return true;
        }
        
        string memory previndex;
        string memory nextindex;

        if(bytes(targetkey).length == 0) { // if it is nil string, or if it belongs at the front
            previndex = nil;
            nextindex = objects[sorted_head].key;
            node memory object1 = node(value, previndex, nextindex, tail, nil, key);
            objects[key] = object1;
            
            objects[nextindex].sorted_prev = key;
            sorted_head = key;
        }
        
        else if(keccak256(bytes(targetkey)) == keccak256(bytes(sorted_tail))) { //if belongs at end
            previndex = targetkey;
            nextindex = nil;
            node memory object2 = node(value, previndex, nextindex, tail, nil, key);
            objects[key] = object2;
            
            objects[previndex].sorted_next = key;
            sorted_tail = key;
        }
        
        else {
            previndex = targetkey;
            nextindex = objects[targetkey].sorted_next;
            node memory object3 = node(value, previndex, nextindex, tail, nil, key);
            objects[key] = object3;
            
            objects[targetkey].sorted_next = key;
            objects[nextindex].sorted_prev = key;
        }

        
        //by default push_back to end of unsorted list
        objects[tail].next = key;
        tail = key;

        length++;
        return true;
    }

    function remove(string targetkey) public returns (bool)
    {
        if(bytes(objects[targetkey].key).length == 0 || length == 0)
        {
            //if the key value is nonexistent or if list is empty
            return false;
        }

        //sorted 
        if(length == 1)
        {
            delete objects[targetkey];
            length--;
            return true;
        }
        
        if(keccak256(bytes(targetkey)) == keccak256(bytes(sorted_head)))
        {
            sorted_head = objects[sorted_head].sorted_next;
            objects[sorted_head].sorted_prev = nil;
        }
        
        else if(keccak256(bytes(targetkey)) == keccak256(bytes(sorted_tail)))
        {
            sorted_tail = objects[sorted_tail].sorted_prev;
            objects[sorted_tail].sorted_next = nil;
        }
        
        else
        {
            string storage sprevkey = objects[targetkey].sorted_prev;
            string storage snextkey = objects[targetkey].sorted_next;
            objects[sprevkey].sorted_next = snextkey;
            objects[snextkey].sorted_prev = sprevkey;
        }

        //unsorted
        if(keccak256(bytes(objects[targetkey].key)) == keccak256(bytes(head)))
        {
            head = objects[targetkey].next;
            objects[head].prev = nil;
        }

        else if(keccak256(bytes(objects[targetkey].key)) == keccak256(bytes(tail)))
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

        delete objects[targetkey];
        length--;
    }
    
    function front() public view returns (string)
    {
        if(length > 0)
        {
            return objects[head].key;
        }
    }

    function back() public view returns (string)
    {
        if(length > 0)
        {
            return objects[tail].key;
        }
    }

    function size() public view returns (int)
    {
        return length;
    }

    function getEntry(string key) public view returns (string, string, string, string, string, string)
    {
        if(bytes(objects[key].key).length == 0)
        {
            return;    
        }
        
        return (objects[key].key, objects[key].value, objects[key].prev, objects[key].next, objects[key].sorted_prev, objects[key].sorted_next);
    }
    
    function getSortedHead() public view returns (string, string, string, string, string, string)
    {
        if(bytes(sorted_head).length == 0)
        {
            return;    
        }
        return (objects[sorted_head].key, objects[sorted_head].value, objects[sorted_head].prev, objects[sorted_head].next, objects[sorted_head].sorted_prev, objects[sorted_head].sorted_next);
    }
    
    function getSortedTail() public view returns (string, string, string, string, string, string)
    {
        if(bytes(sorted_tail).length == 0)
        {
            return;    
        }
        return (objects[sorted_head].key, objects[sorted_head].value, objects[sorted_head].prev, objects[sorted_head].next, objects[sorted_head].sorted_prev, objects[sorted_head].sorted_next);
    }
}



