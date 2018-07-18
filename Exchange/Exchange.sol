pragma solidity ^0.4.9;

import "DLL.sol";

contract Token {
    string public name; 
    uint256 public totalSupply; 
    mapping(address => uint256) balances; //user address to balances 

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /// @param account The address from which the balance will be retrieved
    /// @return The balance
    function getBalance(address account) constant returns(uint256 balance) {
        return balances[account];
    }

    /// @param to the address to which the token will be transferred 
    /// @param value the amount of token to be transferred 
    /// @return whether the transfer was successful 
    function transfer(adress to, uint256 value) returns (bool success) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
        } else { return false; }
    }
}

contract account { 
   DLL allOrders;
   DLL openBuyOrders;
   DLL openSellOrders;
   DLL settledOrders;
   DLL canceledOrders;



   function sellLimitOrder(string tokenName, string price, string amount) {
       string orderKey = keccak256(msg.sender, tokenName, price, amount); //If the orderKey is not empty, then update with higher amount 
       while (bytes(allOrders.getEntry(orderKey)[1]) != 0 ) {
           orderKey = keccak256(orderKey); //get a different orderKey if it already exists       }
       }
       price = 'price:' + price;
       amount = 'amount:' + amount;

       allSellOrders.insert(orderKey, tokenName + price + amount); 
       openSellOrders.insert(orderKey, tokenName + price + amount);
   }
}

contract Exchange{ //Quote Driven market as opposed to order driven market 
    DLL gAllOrders;
    DLL gOpenOrders;
    DLL gSettledOrders;
    DLL gCanceledOrders;

    mapping (address => mapping(address => uint)) public tokens; //token address mapped to mapping of accounts to balance 
    mapping (address => mapping (bytes32=> bool)) public orders; mapping of user accounts to mapping of order 

    function deposit() payable { //tokens[0] represents ethereum
        if (msg.value > 0)
            tokens[0][msg.sender] += msg.value;
    }

    function withdraw(address _to, uint amount) {
        if (tokens[0][msg.sender] < amount) throw; 
        tokens[0][msg.sender] -= amount;
        //transfer to _to address 
    }

    function sellLimitOrder(uint amount, uint price, address token_address) {
        
    }

    function buyLimitOrder(uint amount, address token_address) {

    }

    function sellMarketOrder(uint amount) {

    }

    function buyMarketOrder(uint amount) {

    }

    function settle() {

    }

    function cancelOrder() {

    }
     
}
