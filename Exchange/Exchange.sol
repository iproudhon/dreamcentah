pragma solidity ^0.4.9;

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

contract Exchange{ 
    address public admin;
    address public feeAccount; //account to receive fee 
    uint public fee; //percentage times 
    mapping (address => mapping(address => uint)) public tokens; //token address mapped to mapping of accounts to balance 
    mapping (address => mapping (bytes32=> bool)) public orders; mapping of user accounts to mapping of order 

    function deposit() payable {

    }

    function withdraw(uint amount) {

    }

    function sellLimitOrder(uint amount, address token_address) {

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
