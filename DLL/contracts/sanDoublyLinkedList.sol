pragma solidity ^0.4.24;

import "./stringUtils.sol";

contract sanDoublyLinkedList
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
    string public sroted_tail;
    string public head;
    string public tail;

    mapping(string=>node) private objects;

    function push_back(string key, string value) public returns (bool)
    {
        if(bytes(objects[key].value).length != 0)
        {
            //if the key is already in use
            return;
        }

        if(length == 0)
        {
            node memory object = node(value, "NULL","NULL", key);
            objects[key] = object;
            head = key;
            tail = head;
        }

        else
        {
            node memory obj = node(value, tail, "NULL", key);
            objects[key] = obj;
            objects[tail].next = key;
            tail = key;
        }

        length++;
    }

    function push_front(string key, string value) public returns (bool)
    {
       // string id = keccak256(object.key, object.value, now, length);
        if(length == 0)
        {
            node memory object = node(value, "NULL", "NULL", key);
            objects[key] = object;
            head = key;
            tail = head;
        }

        else
        {
            node memory obj = node(value, "NULL", head, key);
            objects[key] = obj;
            objects[head].prev = key;
            head = key;
        }

        length++;
    }

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

        if(keccak256(bytes(objects[targetkey].key)) == keccak256(bytes(head)))
        {
            head = objects[targetkey].next;
            objects[head].prev = "NULL";
            delete objects[targetkey];
        }

        else if(keccak256(bytes(objects[targetkey].key)) == keccak256(bytes(tail)))
        {
            tail = objects[targetkey].prev;
            objects[tail].next = "NULL";
            delete objects[targetkey];
        }

        else //if the entry is at neither the head or the tail of the list, at least 3 entries
        {
            string storage prevkey = objects[targetkey].prev;
            string storage nextkey = objects[targetkey].next;
            objects[prevkey].next = nextkey;
            objects[nextkey].prev = prevkey;
            delete objects[targetkey];
        }

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

    function insert(string key, string value) public returns(bool)
    {

    }

}


