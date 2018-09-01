var Web3 = require('web3');
var web3;
var exchangeContract;
var exchange;
$(document).ready(function() {
    
    web3 = new Web3(new Web3.providers.HttpProvider('http://172.18.0.1:30303'));
    console.log('ready');
    if (web3.isConnected())
        console.log('connected!');
    web3.eth.defaultAccount = web3.eth.accounts[0];

    exchangeContract = web3.eth.contract([{"constant":true,"inputs":[{"name":"orderKey","type":"bytes32"}],"name":"giveCurrency","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"orderKey","type":"bytes32"}],"name":"getAmount","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"tail","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"targetkey","type":"bytes32"}],"name":"putSettle","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"account","type":"address"},{"name":"currencyName","type":"string"}],"name":"getBalance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"account","type":"address"},{"name":"currencyName","type":"string"},{"name":"amount","type":"uint256"}],"name":"withdraw","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"length","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"buy_length","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"orderKey","type":"bytes32"}],"name":"getPrice","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"orderKey","type":"bytes32"},{"name":"amount","type":"uint256"}],"name":"partiallyFilled","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"sell_head","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"orderKey","type":"bytes32"}],"name":"getStatus","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"buy_tail","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"orderKey","type":"bytes32"}],"name":"getPrev","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"orderKey","type":"bytes32"}],"name":"getFilled","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"account","type":"address"}],"name":"demo_inactiveCancel","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"head","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"buy_head","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"orderKey","type":"bytes32"}],"name":"getNext","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"cancelled_length","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"targetkey","type":"bytes32"}],"name":"remove","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"settled_length","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"settled_head","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"sell_length","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"account","type":"address"},{"name":"pos","type":"uint256"}],"name":"accountOrder","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"nonce","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"cancelled_tail","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"account","type":"address"}],"name":"demo_inactiveSettle","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"targetkey","type":"bytes32"}],"name":"cancel","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"settled_tail","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"orderKey","type":"bytes32"},{"name":"newAmount","type":"uint256"}],"name":"setAmount","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"getOrderKey","outputs":[{"name":"key","type":"bytes32"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"cancelled_head","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"orderKey","type":"bytes32"}],"name":"getAccount","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"orderKey","type":"bytes32"}],"name":"getCurrency","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"sell_tail","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"accountOrderLength","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"sizes","outputs":[{"name":"","type":"uint256"},{"name":"","type":"uint256"},{"name":"","type":"uint256"},{"name":"","type":"uint256"},{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"account","type":"address"},{"name":"orderkey","type":"bytes32"},{"name":"giveCurrencyName","type":"string"},{"name":"getCurrencyName","type":"string"},{"name":"price","type":"uint256"},{"name":"amount","type":"uint256"}],"name":"createLimitOrder","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"account","type":"address"},{"name":"currencyName","type":"string"},{"name":"amount","type":"uint256"}],"name":"deposit","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"price","type":"uint256"},{"name":"giveCurrency","type":"int256"}],"name":"getTargetKey","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"account","type":"address"},{"name":"orderKey","type":"bytes32"},{"name":"giveCurr","type":"string"},{"name":"getCurr","type":"string"},{"name":"price","type":"uint256"},{"name":"amount","type":"uint256"}],"name":"insert","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"}]);

    exchange = exchangeContract.at('0x3df7b1cfb7fadb43f3d06b959c063414b3996f43');
    console.log(exchange);
    var button = document.getElementById('button');
    button.addEventListener('click', function() {
        for (i = 0; i < 4; i++) {
            deposit(eth.accounts[i], 'USD', 100000);
            deposit(eth.accounts[i], 'BitCoin', 100000);
        }
    });

    function deposit(account, currencyName, amount) {
        exchange.deposit(account, currencyName, amount, {from:eth.accounts[0], gas:70000});  
    }

    function withdraw(account, currencyName, amount) {
        exchange.withdraw(account, currencyName, amount, {from:eth.accounts[0], gas:70000});
    }

    function showBalance() {
        var USD0 = exchange.getBalance(eth.accounts[0], 'USD');
        var USD1 = exchange.getBalance(eth.accounts[1], 'USD');
        var USD2 = exchange.getBalance(eth.accounts[2], 'USD');
        var USD3 = exchange.getBalance(eth.accounts[3], 'USD');

        var BitCoin0 = exchange.getBalance(eth.accounts[0], 'BitCoin');
        var BitCoin1 = exchange.getBalance(eth.accounts[1], 'BitCoin');
        var BitCoin2 = exchange.getBalance(eth.accounts[2], 'BitCoin');
        var BitCoin3 = exchange.getBalance(eth.accounts[3], 'BitCoin');

        var balance0 = '0 + USD: ' + USD0 + ' BitCoin: ' + BitCoin0;
        var balance1 = '1 + USD: ' + USD1 + ' BitCoin: ' + BitCoin1;
        var balance2 = '2 + USD: ' + USD2 + ' BitCoin: ' + BitCoin2;
        var balance3 = '3 + USD: ' + USD3 + ' BitCoin: ' + BitCoin3;

        $('Account Balance').find('li')[0].innerText = balance0;
        $('Account Balance').find('li')[1].innerText = balance1;
        $('Account Balance').find('li')[2].innerText = balance2;
        $('Account Balance').find('li')[3].innerText = balance3;
    }

    function  getData() {
        // data will be in string form - how should I organize it then? idk I'll try to find this out tomorrow 
        //get data from Exchange Contract
        //organize buy content and sell content

        //append the buy content and sell content
        var BuyContent = $()
    }

    function initiateAccounts() {
        //populate the data 
    }

});
