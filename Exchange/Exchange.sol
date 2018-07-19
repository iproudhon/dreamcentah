pragma solidity ^0.4.9;

contract Currency {
    string public name; 
    uint256 public totalSupply; 
    mapping(address => uint256) balances; //user address to balances 

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /// @param account The address from which the balance will be retrieved
    /// @return The balance
    function getBalance(address account) public view returns(uint256 balance) {
        return balances[account];
    }

    /// @param to the address to which the token will be transferred 
    /// @param value the amount of token to be transferred 
    /// @return whether the transfer was successful 
    function transfer(address to, uint256 value) public returns (bool success) {
        if (balances[msg.sender] >= value && balances[to] + value > balances[to]) {
            balances[msg.sender] -= value;
            balances[to] += value;
            emit Transfer(msg.sender, to, value);
            return true;
        } else {return false;}
    }
}

contract Exchange {
    exDLL Orders; //sell and buy order should be ordered according to price
    
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
    uint public canceled_length = 0;
    uint public settled_length = 0;
    bytes32 public sell_head;
    bytes32 public sell_tail;
    bytes32 public buy_head;
    bytes32 public buy_tail;
    bytes32 public canceled_head;
    bytes32 public canceled_tail;
    bytes32 public settled_head; 
    bytes32 public settled_tail; 
    bytes32 public head;
    bytes32 public tail;
    string constant nil = "";

    event Order (
        bytes32 orderKey,
        address account, 
        string giveCurrencyName, 
        string getCurrencyName, 
        string price, 
        string amount
    );

    address[] public accounts;

    mapping(bytes32=>order) private orders; //mapping of orderkeys to order objects
    mapping (address => bytes32[]) public accountOrders; //mapping of account address to orderKeys
    mapping (string => address) public currencies; //mapping of token name to token address 

    event order(address account, string giveCurrencyName, string getCurrencyName, string price, string amount);
    
    function deposit()  public payable { //tokens[0] represents ethereum
        if (msg.value > 0)
            currencies[0][msg.sender] += msg.value;
    }

    function withdraw(address _to, uint amount) public {
        if (tokens[0][msg.sender] < amount) revert();
        tokens[0][msg.sender] -= amount;
        //transfer to _to address 
    }

    function createLimitOrder(
        address account, 
        bytes32 orderkey,
        string giveCurrencyName, //give currency fund should be checked 
        string getCurrencyName, 
        string price,
        string amount
    ) 
        public 
    { 
        insert(account, orderKey, giveCurrencyName, getCurrencyName, price, amount);
        
        //connect the account to the order 
        accountOrders[account].put(orderKey);

        emit Order(orderKey, account, giveCurrencyName, getCurrencyName, price, amount);
    }
    
    function createMarketOrder(address account, string giveCurrencyName, string getCurrencyName, string amount) public {
        string price = getMarketPrice(giveCurrencyName, getCurrencyName); 
        createLimitOrder(account, giveCurrencyName, getCurrencyName, price, amount);
    }

    function getMarketPrice(strig giveCurrencyName, string getCurrencyName) public { 
        
    
    }

    function cancelOrder(bytes32 targetOrderKey) public {
        cancel(targetOrderKey); 
    }

    function settle() public {
    //matches the buy order and sell order and allocate the tokens being exchanged into the correct accounts
    //update the status of the orders on account level and global level
        while (Orders.needSettle()) {
            sellOrder = Orders.getElement(Orders.sellTail()); //use log later 
            uint fill = 0;
            uint sellAmount;
            uint sellPrice; 
            uint buyAmount; 
            uint buyPrice;
            string[] matchingBuys; //array to store matching buy orders for a sell order 
            while(fill < sellAmount && buyPrice >= sellPrice) {
                buyOrder = Orders.getElement(Orders.buyHead());
                if(buyAmount > sellAmount - fill) {
                    fill = sellAmount; 
                    
                }
                else if (buyAmount < sellAmount - fill) {
                    fill += buyAmount; 
                    matchingBuys.put(buyOrder.orderKey);
                }
                else if (buyAmount == sellAmount - fill) { 
                    fill = buyAmount; 
                    matchingBuys.put(buyuOrder.orderKey);
                }

            }

        }
        Orders.settle();
    }

    function insert(
        address _account,
        bytes32 orderKey,
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
        _order.account = _account;
        _order.giveCurrencyName = _giveCurrencyName;
        _order.getCurrencyName = _getcurrencyName;
        _order.price = _price;
        _order.amount = _amount;
        orders[orderKey] = _order;
         
        head = orderKey; 
        tail = orderKey;
        
        if(length == 0) {
            head = orderKey;
            tail = orderKey;

            if(keccak256(_giveCurrencyName) == keccak256("USD") {
                buy_head = orderKey;
                buy_tail = orderKey;
                buy_length++;
            }
            else if(keccak256(_giveCurrencyName) == keccak256("BitCoin")) {
                sell_head = orderKey;
                sell_tail = orderKey;
                sell_length++;
            }
            length++;
            return true; 
        }
        
        //cannot just put in previous if statement as it can't set the head that is not the first
        if(_giveCurrencyName == "USD" && buy_length == 0) {
            buy_head = orderKey; 
            buy_tail = orderKey; 
            buy_length++;
        }
        //regular case where sell_length > 0
        else if(_giveCurrencyName == "USD") { // if it is s sell at the start of string
            orders[orderKey].status_prev = buy_tail; 
            orders[buy_tail].status_next = orderKey; 
            buy_tail = orderKey; 
            buy_length++;
        }
            
        //cannot just put in previous if statement as it can't set the head that is not the first
        if(_giveCurrencyName == "BitCoin" && sell_length == 0) {
            sell_head = orderKey; 
            sell_tail = orderKey; 
            sell_length++;
        }
        //regular case where sell_length > 0
        else if(_giveCurrencyName == "BitCoin") { // if it is s sell at the start of string
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
        remove(targetkey);
        if (canceled_length == 0) {
            canceled_head = targetkey;
            canceled_tail = targetkey;
            canceled_length++;
        } else {
            orders[canceled_tail].status_next = targetkey;
            orders[targetkey].status_prev = canceled_tail;
            canceled_tail = targetkey;
            canceled_length++; 
        }
    }

    function remove(bytes32 targetkey) public returns (bool) { //does not destroy the object, just takes it out of the buy and sell order list 
        if(bytes(orders[targetkey].key).length == 0 || length == 0) {
            //if the key value is nonexistent or if list is empty
            return false;
        }
        
        //for buy list
        if(orders[targetkey].giveCurrencyName == "USD") {
            if(targetkey == buy_head) {
                buy_head = orders[buy_head].status_next;
                orders[buy_head].status_prev = nil;
            } else if(targetkey == buy_tail) {
                buy_tail = orders[buy_tail].status_prev;
                orders[buy_tail].status_next = nil;
            } else {
                bytes32 bprevkey = orders[targetkey].status_prev;
                bytes32 bnextkey = orders[targetkey].status_next;
                orders[bprevkey].sell_next = bnextkey;
                orders[bnextkey].sell_prev = bprevkey;
            }
        }
        
        //for sell list
        if(orders[targetkey].giveCurrencyName == "BitCoin") { 
            if(targetkey == sell_head) {
                sell_head = orders[sell_head].status_next;
                orders[sell_head].status_prev = nil;
            } else if(targetkey == sell_tail) {
                sell_tail = orders[sell_tail].status_prev;
                orders[sell_tail].status_next = nil;
            } else {
                bytes32 sprevkey = orders[targetkey].status_prev;
                bytes32 snextkey = orders[targetkey].status_next;
                orders[sprevkey].sell_next = snextkey;
                orders[snextkey].sell_prev = sprevkey;
            }
            sell_length--;
        }
    }

    function sizes() public view returns (int, int, int) {
        return (length, sell_length, buy_length);
    }

    function getEntry(bytes32 key) public view returns (string, string, string, string) {
        if(orders[key].key.length == 0) 
            return;    
        
        //key, value, prev, next, sell_prev, sell_next, buy_prev, buy_next
        return (orders[key].key, orders[key].value, orders[key].prev, orders[key].next, orders[key].status_next, orders[key].status_next);
    }
    
    function getSellHead() public view returns (string, string, string, string) {
        if(sell_head.length == 0)
            return;    
        
        return (orders[sell_head].key, orders[sell_head].value, orders[sell_head].sell_prev, orders[sell_head].sell_next);
    }
    
    function getSellTail() public view returns (string, string, string, string) {
        if(sell_tail.length == 0)
            return;    
        
        return (orders[sell_tail].key, orders[sell_tail].value, orders[sell_tail].sell_prev, orders[sell_tail].sell_next);
    }
    
    function getBuyHead() public view returns (string, string, string, string) {
        if(buy_head.length == 0) 
            return;    
        
        return (orders[buy_head].key, orders[buy_head].value, orders[buy_head].buy_prev, orders[buy_head].buy_next);
    }
    
    function getBuyTail() public view returns (string, string, string, string) {
        if(buy_tail.length == 0)
            return;    
        
        return (orders[buy_tail].key, orders[buy_tail].value, orders[buy_tail].buy_prev, orders[buy_tail].buy_next);
    }
}
