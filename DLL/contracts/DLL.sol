pragma solidity ^0.4.24;

import "./StringUtils.sol";

//There are two types of links-> ordered and unordered. unordered list contains nodes that are put in order as they are put inserted to the list. the ordered list maintains the order of the nodes based on key of each node
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

    function pop_front() public returns (bool)
    {
        if(length == 0)
        {
            return false;
        }

        if(length == 1)
        {
            head = "NULL";
            tail = "NULL";
        }
        else
        {
            head = objects[head].next;
            objects[head].prev = "NULL";
        }

        length--;
    }

    function pop_back() public returns (bool)
    {
        if(length == 0)
        {
            return false;
        }

        if(length == 1)
        {
            head = "NULL";
            tail = "NULL";
        }
        else
        {
            tail = objects[tail].prev;
            objects[tail].next = "NULL";
        }

        length--;
    }

    function remove(string targetkey) public returns (bool)
    {
        if(bytes(objects[targetkey].value).length == 0 || length == 0)
        {
            //if the key value is nonexistent or if list is empty
            return false;
        }

        if(length == 1)
        {
            delete objects[targetkey];
            length--;
            return true;
        }

        if(StringUtils.equal(targetkey, head))
        {
            head = objects[targetkey].next;
            objects[head].prev = "NULL";
        }
        else if(StringUtils.equal(targetkey, tail))
        {
            tail = objects[targetkey].prev;
            objects[tail].next = "NULL";
        }
        else //if the entry is at neither the head or the tail of the list, at least 3 entries
        {
            string storage prevkey = objects[targetkey].prev;
            string storage nextkey = objects[targetkey].next;
            objects[prevkey].next = nextkey;
            objects[nextkey].prev = prevkey;
        }

        if (StringUtils.equal(targetkey, sorted_head))
        {
            sorted_head = objects[targetkey].sorted_next;
            objects[sorted_head].sorted_prev = "NULL";
        }
        else if(StringUtils.equal(targetkey, sorted_tail))
        {
            sorted_tail = objects[targetkey].sorted_prev;
            objects[sorted_tail].sorted_next = "NULL";
        }
        else
        {
            string memory sorted_prevkey = objects[targetkey].sorted_prev;
            string memory sorted_nextkey = objects[targetkey].sorted_next;
            objects[sorted_prevkey].sorted_next = sorted_nextkey;
            objects[sorted_nextkey].sorted_prev = sorted_prevkey;
        }

        delete objects[targetkey];
        length--;
        return true;
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

    function clear() public returns (bool)
    {
        while(length > 0)
        {
            pop_back();
        }
    }

    function getEntry(string key) public view returns (string, string, string, string)
    {
        return (objects[key].key, objects[key].value, objects[key].prev, objects[key].next);
    }

    function getLength() public view returns (int)
    {
        return length;
    }

    function insert(string key, string value) public returns (bool)
    {
        if(bytes(objects[key].value).length != 0)
        {
            //if the key is already in use
            return false;
        }

        node memory object;
        if(length == 0)
        {
            object = node(value, key, key, key, key, key);
            objects[key] = object;
            return true;
        }

        //for ordered link
        string memory temp = sorted_head;
        while (StringUtils.compare(temp, key) == -1)
        { //linear search until key is placed at the right place
            temp = objects[temp].sorted_next;
        }
        //insert before temp in the ordered list and push_back for unordered list
        object = node(value, objects[temp].sorted_prev, temp, tail, "NULL", key);
        objects[object.sorted_prev].sorted_next = key;
        objects[temp].sorted_prev = key;
        objects[tail].next = key;
        objects[key] = object;
        tail = key;
        length++;
    }
}
