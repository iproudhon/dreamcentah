pragma solidity ^0.4.0;

contract LinkedList { 
    
    bytes32 constant NULL_NODE_ID = keccak256("NULL");
    
    struct Node {
        bytes32 prev;
        bytes32 next;
        string data; 
    }
    
    bytes32 _front;
    bytes32 _back;
    Node _front_node;
    Node _back_node;
    uint public size;
    
    mapping(bytes32=>Node) nodes;
    
    constructor() public payable {
        //setting the bytess32 front and back 
        _front = NULL_NODE_ID;
        _back = NULL_NODE_ID;
        _front_node.next = _back;
        _back_node.prev = _front; 
        size = 0;
    }
    
    function size() public constant returns(uint sz) {
        return size;
    }
    
    function empty() public returns(bool _empty) {
        return size == 0;
    }
    
    event print_data(string data);
    
    function push_front(string data) public {
        insert(_front, nodes[_front].next, data);
    }
    
    function push_back(string data) public {
        insert(nodes[_back].prev, _back, data);
    }
    
    function front() public{
        emit print_data(nodes[_front].data);
    }
    
    function back() public{
        emit print_data(nodes[_back].data);
    }
    

    function pop_front() public {
        remove(_front);
    }
    
    function pop_back() public {
        remove(_back);
    }
    
    function insert(bytes32 _prev, bytes32 _next, string _data) public {
        if (size == 0) {
            require(_prev == _front && _next == _back);
            Node memory new_node; 
            new_node.prev = _prev; 
            new_node.next = _next; 
            new_node.data = _data;
            bytes32 new_node_id = keccak256(_data, _prev, _next);
            _front_node.next = new_node_id;
            _back_node.prev = new_node_id; 
            size++;
        }
        else {
            Node memory _new_node; 
            _new_node.prev = _prev; 
            _new_node.next = _next; 
            _new_node.data = _data;
            new_node_id = keccak256(_data, _prev, _next);
            nodes[_prev].next = new_node_id;
            nodes[_next].prev = new_node_id;
            size++;
        }
        
    }
    
    function remove(bytes32 node_id) public {
        nodes[nodes[node_id].next].prev = nodes[node_id].prev;
        nodes[nodes[node_id].prev].next = nodes[node_id].next;
        delete nodes[node_id];
        size--;
    }
    
    
}

