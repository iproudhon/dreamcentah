pragma solidity ^0.4.9;

contract Token {
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

contract account {
    address public owner = msg.sender;
    Exchange exchange;  
    exDLL Orders;

    //Token address to balance 

    function sellLimitOrder(string tokenName, string price, string amount) public {
        
        //If the orderKey is not empty, then update with higher amount 
        string memory orderKey = bytes32ToString(keccak256(msg.sender, tokenName, price, amount));
       
        while (bytes(Orders.getEntry(orderKey)[1]).length != 0 ) {
            orderKey = bytes32ToString(keccak256(orderKey)); //get a different orderKey if it already exists
        }
        string storage _orderKey = "s" + orderKey;
        string storage _price = "price:" + price;
        string storage _amount = "amount:" + amount;
        string storage orderDetails = tokenName + _price + _amount;

        Orders.insert(_orderKey, orderDetails);
        exchange.sellOrder(_orderKey, orderDetails); //also put this into the global level
        
        return (orderKey, orderDetails);
    }

    function buyLimitOrder(string tokenName, string price, string amount) public {
      //checking if the account has sufficient fund will be done outside
        string storage orderKey = bytes32ToString(keccak256(msg.sender, tokenName, price, amount));
        while (bytes(Orders.getEntry(orderKey)[1]).length != 0 ) {
            orderKey = bytes32ToString(keccak256(orderKey)); //get a different orderKey if it already exists
        }
        string storage _orderKey = "b" + orderKey;
        string storage _price = "price:" + price;
        string storage _amount = "amount:" + amount;
        string storage orderDetails = tokenName + _price + _amount;

        Orders.insert(_orderKey, orderDetails);
        exchange.createOrder(_orderKey, orderDetails); 
        return (orderKey, orderDetails);
    }

    function sellMarketOrder(string tokenName, string amount) public {
        string storage price = exchange.getMarketSellPrice();
        sellLimitOrder(tokenName, price, amount);
    }

    function buyMarketOrder(string tokenName, string amount) public {
        string storage price = exchange.getMarketBuyPrice();
        buyLimitOrder(tokenName, price, amount);
    }

    function cancelOrder(string orderKey) public {
        Orders.cancel(orderKey); //this will move the order to the canceled list 
    }

    function settleOrder(string orderKey) public { 
        Orders.settle(orderKey); //this will move the order to the settled list 
    }

    function bytes32ToString(bytes32 x) internal view returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
    
}

contract Exchange {
    exDLL Orders; //sell and buy order should be ordered according to price 
    mapping (string => address) public tokens; //mapping of token name to token address 

    function deposit()  public payable { //tokens[0] represents ethereum
        if (msg.value > 0)
            tokens[0][msg.sender] += msg.value;
    }

    function withdraw(address _to, uint amount) public {
        if (tokens[0][msg.sender] < amount) revert(); 
        tokens[0][msg.sender] -= amount;
        //transfer to _to address 
    }

    function createOrder(string orderKey, string orderDetails) public {
        Orders.insert(orderKey, orderDetails);
    }

    function getMarketPrice() public { //takes an average of highest buy price and lowest sell price  
         
    }

    function settle() public { //matches the buy order and sell order and allocate the tokens being exchanged into the correct accounts
    //update the status of the orders on account level and global level
    
    }

    function cancelOrder() public {
    }
     
}
