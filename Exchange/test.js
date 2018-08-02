function createAccounts() {
  for (i = 0; i < 1000; i++)
    personal.newAccount("1");
  for (i = 0; i < 1000; i++)
    personal.unlockAccount(eth.accounts[i], "1", 36000);  
} 

function depositAccounts() { 
  for (i = 0; i < 1000; i++) {
    deposit(eth.accounts[i], 'USD', 10000);
    deposit(eth.accounts[i], 'BitCoin', 10000);
  }
}

function prePopulate() {
  var price;
  var amount;
  miner.start(1);
  for(i = 0; i<1000; i++) {
    var buy_ = Math.floor(Math.random()*4);
    var sell_ = Math.floor(Math.random()*4);

    for(var j = 0; j < buy_; j++) {
      //active orders make it random - buy/sell,  number of order to make(0-3), order price(6000-6500), amount(0-1000), 
      price = Math.floor(6000 + Math.random()*500);
      amount = Math.floor(Math.random()*1000);
      createLimitOrder(eth.accounts[i],'USD','BitCoin', price, amount);
    }

    for(var p = 0; p < sell_; p++) {
      price = 6000 + Math.floor(Math.random()*500);
      amount = Math.floor(Math.random()*1000);
      createLimitOrder(eth.accounts[i],'BitCoin','USD', price, amount )
    }
  }
  miner.stop();
}

function populateInactive() {
  for (i = 0; i < 1000; i++) {
    for(var k = 0; k<100; k++) {
      Exchange.demo_inactiveSettle(eth.accounts[i]);
      Exchange.demo_inactiveCancel(eth.accounts[i]);
    }
  }
}

function initiateAccounts() {
  deposit(eth.accounts[0], 'USD', 10000);
  deposit(eth.accounts[1], 'USD', 10000);
  deposit(eth.accounts[2], 'USD', 10000);
  deposit(eth.accounts[3], 'USD', 10000);
  deposit(eth.accounts[0], 'BitCoin', 10000);
  deposit(eth.accounts[1], 'BitCoin', 10000);
  deposit(eth.accounts[2], 'BitCoin', 10000);
  deposit(eth.accounts[3], 'BitCoin', 10000);
  mine();
  showBalance();
}

function showBalance() { 
  var USD0 = Exchange.getBalance(eth.accounts[0], 'USD');
  var USD1 = Exchange.getBalance(eth.accounts[1], 'USD');
  var USD2 = Exchange.getBalance(eth.accounts[2], 'USD');
  var USD3 = Exchange.getBalance(eth.accounts[3], 'USD');
  
  var BitCoin0 = Exchange.getBalance(eth.accounts[0], 'BitCoin');
  var BitCoin1 = Exchange.getBalance(eth.accounts[1], 'BitCoin');
  var BitCoin2 = Exchange.getBalance(eth.accounts[2], 'BitCoin');
  var BitCoin3 = Exchange.getBalance(eth.accounts[3], 'BitCoin');
  
  console.log('0 + USD: ' + USD0 + ' BitCoin: ' + BitCoin0);
  console.log('1 + USD: ' + USD1 + ' BitCoin: ' + BitCoin1);
  console.log('2 + USD: ' + USD2 + ' BitCoin: ' + BitCoin2);
  console.log('3 + USD: ' + USD3 + ' BitCoin: ' + BitCoin3);

}

function testOrders1() {
  createLimitOrder(eth.accounts[0], 'USD', 'BitCoin', 1000, 1);
  createLimitOrder(eth.accounts[1], 'BitCoin', 'USD', 1000, 1);
  mine();
}


function testOrders2() {
  createLimitOrder(eth.accounts[0], 'USD', 'BitCoin', 1000, 3);
  createLimitOrder(eth.accounts[1], 'BitCoin', 'USD', 1000, 1);  
  createLimitOrder(eth.accounts[2], 'BitCoin', 'USD', 1000, 1);
  mine();
}

function testOrders3() {
  createLimitOrder(eth.accounts[0], 'USD', 'BitCoin', 1000, 1);
  createLimitOrder(eth.accounts[1], 'BitCoin', 'USD', 1100, 1);
  mine();
}

function testOrders4() {
  createLimitOrder(eth.accounts[0], 'USD', 'BitCoin', 1200, 3);
  createLimitOrder(eth.accounts[1], 'BitCoin', 'USD', 1200, 1);
  createLimitOrder(eth.accounts[2], 'BitCoin', 'USD', 1100, 1);
  mine();
}

function testOrders5() {
  createLimitOrder(eth.accounts[0], 'USD', 'BitCoin', 900, 2);
  createLimitOrder(eth.accounts[1], 'BitCoin', 'USD', 1000, 3);
  createLimitOrder(eth.accounts[2], 'USD', 'BitCoin', 1100, 1);
  createLimitOrder(eth.accounts[3], 'BitCoin', 'USD', 900, 3);
  mine();
}

function testOrders6() {
  createMarketOrder(eth.accounts[0], 'USD', 'BitCoin', 5);
  createMarketOrder(eth.accounts[1], 'BitCoin', 'USD', 5);
  mine();
}

function createLimitOrder(account, giveCurrency, getCurrency, price, amount) {
  var orderkey = Exchange.getOrderKey({from:eth.accounts[0], gas:50000});
  Exchange.createLimitOrder(account, orderkey, giveCurrency, getCurrency, price, amount, {from:eth.accounts[0], gas:1000000});
}

function createMarketOrder(account, giveCurrency, getCurrency, amount) {
  var price = getMarketPrice();
  var orderKey = Exchange.getOrderKey({from:eth.accounts[0], gas:50000});
  Exchange.createLimitOrder(account, orderKey, giveCurrency, getCurrency, price, amount, {from:eth.accounts[0], gas:1000000});
}

function getMarketPrice() {
  if (Exchange.buy_length() == 0|| Exchange.sell_length() == 0) {
    var settled_tail = Exchange.settled_tail();
    var marketPrice = getOrderInfo(settled_tail)[3];
    return marketPrice;
  } else {
    var buy_head = Exchange.buy_head();
    var sell_tail = Exchange.sell_tail();
    var buy_price = getOrderInfo(buy_head)[3];
    var sell_price = getOrderInfo(sell_tail)[3];
    var marketPrice = Math.round((buy_price + sell_price) / 2);
    return marketPrice;
  }
}

function settle() {
  var settledOrderCount = 0; 
  var buyOrderKey;
  var sellOrderKey;
  var prevBuyorderKey;
  var buyPrice;
  var sellPrice;
  var buyAmount;
  var sellAmount;
  var buyAccount;
  var sellAccount;

  buyOrderKey = Exchange.buy_head(); //highest buy price orderkey
  sellOrderKey = Exchange.sell_tail(); //lowest sell price order key 

  buyPrice = Number(Exchange.getPrice(buyOrderKey));
  sellPrice = Number(Exchange.getPrice(sellOrderKey));

  while (buyPrice >= sellPrice && Exchange.sizes()[1] > 0 && Exchange.sizes()[2] > 0) { //buy Length and sell length both greater than 0
    if (Number(Exchange.getStatus(buyOrderKey)) == 1)
      buyAmount = Number(Exchange.getAmount(buyOrderKey)) - Number(Exchange.getFilled(buyOrderKey)); //remaining buy Order amount
    else
      buyAmount = Number(Exchange.getAmount(buyOrderKey));
    
    if (Number(Exchange.getStatus(sellOrderKey)) == 1)
      sellAmount = Number(Exchange.getAmount(sellOrderKey)) - Number(Exchange.getFilled(sellOrderKey));
    else
      sellAmount = Number(Exchange.getAmount(sellOrderKey));  
    
    buyAccount = Exchange.getAccount(buyOrderKey);
    sellAccount = Exchange.getAccount(sellOrderKey);

    if (buyAmount > sellAmount) {
      deposit(buyAccount, "BitCoin", sellAmount); 
      withdraw(buyAccount, "USD", sellAmount * buyPrice);
      deposit(sellAccount, "USD", sellAmount * buyPrice);
      withdraw(sellAccount, "BitCoin", sellAmount);
      
      Exchange.partiallyFilled(buyOrderKey, sellAmount, {from:eth.accounts[0], gas:50000});

      prevSellOrderKey = Exchange.getPrev(sellOrderKey);
      Exchange.putSettle(sellOrderKey, {from: eth.accounts[0], gas:500000});

      sellOrderKey = prevSellOrderKey;
      sellPrice = Number(Exchange.getPrice(sellOrderKey));

      mine();
      settledOrderCount += 1; 
      console.log('1 order settled');

    } else if (sellAmount > buyAmount) { 
      deposit(buyAccount, "BitCoin", buyAmount); 
      withdraw(buyAccount, "USD", buyAmount * buyPrice);
      deposit(sellAccount, "USD", buyAmount * buyPrice);
      withdraw(sellAccount, "BitCoin", buyAmount);
      
      Exchange.partiallyFilled(sellOrderKey, buyAmount, {from:eth.accounts[0], gas:50000});
      
      nextBuyOrderKey = Exchange.getNext(buyOrderKey);
      Exchange.putSettle(buyOrderKey, {from: eth.accounts[0], gas:500000});
      
      buyOrderKey = nextBuyOrderKey;
      buyPrice = Number(Exchange.getPrice(buyOrderKey));

      mine();
      settledOrderCount += 1;
      console.log('1 order settled');

    } else if (sellAmount == buyAmount) {
      deposit(buyAccount, "BitCoin", sellAmount); 
      withdraw(buyAccount, "USD", sellAmount * buyPrice);
      deposit(sellAccount, "USD", sellAmount * buyPrice);
      withdraw(sellAccount, "BitCoin", sellAmount);
      
      Exchange.partiallyFilled(buyOrderKey, buyAmount, {from:eth.accounts[0], gas:500000}); //100% filled
      Exchange.partiallyFilled(sellOrderKey, sellAmount, {from:eth.accounts[0], gas:500000});
      
      nextBuyOrderKey = Exchange.getNext(buyOrderKey);
      prevSellOrderKey = Exchange.getPrev(sellOrderKey);
      Exchange.putSettle(buyOrderKey, {from: eth.accounts[0], gas:500000});
      Exchange.putSettle(sellOrderKey, {from: eth.accounts[0], gas:500000});
      buyOrderKey = nextBuyOrderKey; 
      sellOrderKey = prevSellOrderKey;
      buyPrice = Number(Exchange.getPrice(buyOrderKey));
      sellPrice = Number(Exchange.getPrice(sellOrderKey));
      
      mine();
      settledOrderCount += 2;
      console.log('2 orders settled');
    }
  }
  console.log('Total settled orders: ' + settledOrderCount);
}

function deposit(account, currencyName, amount) {
  Exchange.deposit(account, currencyName, amount, {from:eth.accounts[0], gas:70000});  
}

function withdraw(account, currencyName, amount) {
  Exchange.withdraw(account, currencyName, amount, {from:eth.accounts[0], gas:70000});
}

function getBalance(account, currencyName) {
  Exchange.getBalance(account, currencyName);
}

function getOrderInfo(orderKey) {
  var account = Exchange.getAccount(orderKey);
  var giveCurrency = Exchange.giveCurrency(orderKey);
  var getCurrency = Exchange.getCurrency(orderKey);
  var price = Number(Exchange.getPrice(orderKey));
  var amount = Number(Exchange.getAmount(orderKey));
  var filled_amount = Number(Exchange.getFilled(orderKey));
  var status;
  var filled_percentage;
  switch (Number(Exchange.getStatus(orderKey))) {
    case 0: 
      status = "open";
      break;
    case 1: 
      status = "partially filled";
      filled_percentage = filled_amount / amount * 100;
      break;
    case 2:
      status = "settled";
      break;
    case 3:
      status = "cancelled";
  }
  return [account, giveCurrency, getCurrency, price, amount, status, filled_percentage];
}

function displayAllOpenOrders() {
//buyOrders 
  var buyLength = Exchange.buy_length();
  var i;
  var buyOrderKey = Exchange.buy_tail(); //from lowest
  var buyOrder;
  var orderPrice; 
  var orderAmount;
  var status;
  var filled_percentage;
  console.log("Buy Orders");
  for (i = 0; i < buyLength; i++) {
    buyOrder = getOrderInfo(buyOrderKey);
    orderPrice = Number(buyOrder[3]);
    orderAmount = Number(buyOrder[4]);
    status = buyOrder[5];
    if (status == "partially filled") {
      filled_percentage = buyOrder[6];
      console.log(orderPrice, " ", orderAmount, " ", filled_percentage, "% filled");
    } else
      console.log(orderPrice, " ", orderAmount);
      
    buyOrderKey = Exchange.getPrev(buyOrderKey);
  }

//sellOrders
  console.log("Sell Orders");
  var sellLength = Exchange.sell_length();
  var sellOrderKey = Exchange.sell_tail(); //from lowest
  for (i = 0; i < sellLength; i++) {
    sellOrder = getOrderInfo(sellOrderKey);
    orderPrice = Number(sellOrder[3]);
    orderAmount = Number(sellOrder[4]);
    status = sellOrder[5];
    if (status == "partially filled") {
      filled_percentage = sellOrder[6];
      console.log(orderPrice, " ", orderAmount, " ", filled_percentage, "% filled");
    } else
      console.log(orderPrice, " ", orderAmount);

    sellOrderKey = Exchange.getPrev(sellOrderKey);
  }
}

function displayOpenOrders(buyLength, sellLength) { //displaying specified amount of orders
  if (Exchange.buy_length() < buyLength)
    buyLength = Exchange.buy_length();
  if (Exchange.sell_length() < sellLength)
    sellLength = Exchange.sell_length();

  var i;
  var buyOrderKey = Exchange.buy_tail(); //from highest
  var buyOrder;
  var orderPrice; 
  var orderAmount;
  var status;
  var filled_percentage;
  console.log("Displaying ", buyLength, " Buy Orders");
  for (i = 0; i < buyLength; i++) {
    buyOrder = getOrderInfo(buyOrderKey);
    orderPrice = Number(buyOrder[3]);
    orderAmount = Number(buyOrder[4]);
    status = buyOrder[5];
    if (status == "partially filled") {
      filled_percentage = buyOrder[6];
      console.log(orderPrice, " ", orderAmount, " ", filled_percentage, "% filled");
    } else
      console.log(orderPrice, " ", orderAmount);
      
    buyOrderKey = Exchange.getPrev(buyOrderKey);
  }

//sellOrders
  console.log("Displaying ", sellLength, " Sell Orders");
  var sellLength = Exchange.sell_length();
  var sellOrderKey = Exchange.sell_tail(); //from lowest
  for (i = 0; i < sellLength; i++) {
    sellOrder = getOrderInfo(sellOrderKey);
    orderPrice = Number(sellOrder[3]);
    orderAmount = Number(sellOrder[4]);
    status = sellOrder[5];
    if (status == "partially filled") {
      filled_percentage = sellOrder[6];
      console.log(orderPrice, " ", orderAmount, " ", filled_percentage, "% filled");
    } else
      console.log(orderPrice, " ", orderAmount);

    sellOrderKey = Exchange.getPrev(sellOrderKey);
  }
}

function displaySettledOrders() {
  var length = Exchange.settled_length();
  var orderKey = Exchange.settled_head();
  var account;
  var orderType;
  var orderPrice;
  var orderAmount;
  for (i = 0; i < length; i++) {
    order = getOrderInfo(orderKey);
    account = order[0].substr(0,10); //abbreviated account address
    
    if (order[1] == "USD") //giveCurrency is USD
      orderType = "Buy";
    else if (order[1] == "BitCoin") //giveCurrency is BitCoin
      orderType = "Sell";
    
    orderPrice = Number(order[3]);
    orderAmount = Number(order[4]);
    console.log(account, " ", orderType, " ", orderPrice, " ", orderAmount);
    orderKey = Exchange.getNext(orderKey);
  }
  return length;
}

function displayCancelledOrders() {
  var length = Exchange.cancelled_length();
  var orderKey = Exchange.cancelled_head();
  var account;
  var orderType;
  var orderPrice;
  var orderAmount;
  for (i = 0; i < length; i++) {
    order = getOrderInfo(orderKey);
    account = order[0].substr(0,10); //abbreviated account address
    
    if (order[1] == "USD") //giveCurrency is USD
      orderType = "Buy";
    else if (order[1] == "BitCoin") //giveCurrency is BitCoin
      orderType = "Sell";
    
    orderPrice = Number(order[3]);
    orderAmount = Number(order[4]);
    console.log(account, " ", orderType, " ", orderPrice, " ", orderAmount);
    orderKey = Exchange.getNext(orderKey);
  }
  return length;
}


function displayAccountOrders(account) {
  var length = Exchange.accountOrderLength(account);
  var i;
  var orderType;
  var orderPrice;
  var orderAmount;
  var orderStatus;
  console.log("Number "+ " Order Type" + " Price " + " Amount " + " Status ");
  for (i = 0; i < length; i++) {
    accountOrder = getOrderInfo(Exchange.accountOrder(account, i));
    if (accountOrder[1] == "USD") //giveCurrency is USD
      orderType = "Buy";
    else if (accountOrder[1] == "BitCoin")
      orderType = "Sell";
    
    orderPrice = Number(accountOrder[3]);
    orderAmount = Number(accountOrder[4]);
    orderStatus = accountOrder[5];
    console.log(i, " ", orderType , " " , orderPrice , " " , orderAmount , " " , orderStatus);
  }
}

function accountSummary(account) {
  var USDBalance;
  var BitCoinBalance;
  
  USDBalance = Exchange.getBalance(account, "USD");
  BitCoinBalance = Exchange.getBalance(account, "BitCoin");

  var simpleAccount = account.substr(0,10); //displaying abbreviated account address
  console.log("Showing Summary for account: ", simpleAccount);
  console.log('USD: ' + USDBalance + ' BitCoin: ' + BitCoinBalance);
  displayAccountOrders(account);
}

function cancel(orderKey) {
  var orderStatus = getOrderInfo(orderKey)[5];
  if (orderStatus == "open") {
    Exchange.cancel(orderKey, {from:eth.accounts[0], gas:500000});
    console.log("Order cancelled");
    mine();
  } else
    console.log("The order status must be open to cancel. current order status: ", orderStatus);
}

function cancelOrder(account, orderNumber) {
  var orderKey;
  orderKey = Exchange.accountOrder(account, orderNumber);
  cancel(orderKey);
}

function marketSummary() {
  var buyLength;
  var sellLength;
  var marketPrice; 

  sellLength = Exchange.sizes()[1];
  buyLength = Exchange.sizes()[2];
  console.log("Total ", buyLength, " buy orders, ", sellLength, " sell orders");
  displayOpenOrders(10, 10); //displaying 10 buy orders, 10 sell orders 
  
  marketPrice = Number(getMarketPrice());

  console.log("Market Price: ", marketPrice);
}

/*
class Account { 
  constructor(password) {
    this.password = password;
    this.address = personal.newAccount("1");
    this.USDBalance = 0;
    this.BitCoinBalance = 0;
    this.orders = [];
  }

  _deposit(currencyName, amount) {
    personal.unlockAccount(this.address, "1", 36000);
    deposit(this.address, currencyName, amount);
  }

  _withdraw(currencyName, amount) {
    personal.unlockAccount(this.address, "1", 36000);
    witdhraw(this.address, currencyName, amount);
  }

  _createLimitOrder() {

  }

  _createMarketOrder() { 

  }

  _displayAccountOrders() { 

  }
}
*/
