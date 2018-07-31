
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
  createLimitOrder(eth.accounts[0], 'USD', 'BitCoin', 1200, 1);
  createLimitOrder(eth.accounts[1], 'BitCoin', 'USD', 900, 1);  
  createLimitOrder(eth.accounts[2], 'BitCoin', 'USD', 300, 1);
  mine();
}

function testOrders3() {
  createLimitOrder(eth.accounts[0], 'USD', 'BitCoin', 900, 1);
  createLimitOrder(eth.accounts[1], 'USD', 'BitCoin', 300, 1);
  createLimitOrder(eth.accounts[2], 'BitCoin', 'USD', 1200, 1);
  mine();
}

function testOrders4() {
  createLimitOrder(eth.accounts[0], 'USD', 'BitCoin', 1000, 1);
  createLimitOrder(eth.accounts[1], 'USD', 'BitCoin', 2000, 1);
  createLimitOrder(eth.accounts[2], 'BitCoin', 'USD', 5000, 1);
  mine();
}

function testOrders5() {
  createLimitOrder(eth.accounts[0], 'USD', 'BitCoin', 5000, 1);
  createLimitOrder(eth.accounts[1], 'BitCoin', 'USD', 1000, 2);
  createLimitOrder(eth.accounts[2], 'BitCoin', 'USD', 1000, 1);
  mine();
}

function testOrders6() {
  showBalance();
  createLimitOrder(eth.accounts[0], 'USD', 'BitCoin', 5000, 1);
  createLimitOrder(eth.accounts[1], 'BitCoin', 'USD', 0, 1);
  createLimitOrder(eth.accounts[2], 'BitCoin', 'USD', 1000, 2);
  mine();
}

function testOrders7() {
  showBalance();
  createLimitOrder(eth.accounts[0], 'USD', 'BitCoin', 0, 1);
  createLimitOrder(eth.accounts[1], 'BitCoin', 'USD', 100, 1);
  createLimitOrder(eth.accounts[2], 'BitCoin', 'USD', 1000, 2);
  mine();
}

function testOrders8() {
  showBalance();
  createLimitOrder(eth.accounts[0], 'USD', 'BitCoin', 0, 1);
  createLimitOrder(eth.accounts[1], 'BitCoin', 'USD', 100, 1);
  createLimitOrder(eth.accounts[2], 'BitCoin', 'USD', 1000, 2);
  mine();
  settle();
  console.log('after settling');
  showBalance();
}

function createLimitOrder(account, giveCurrency, getCurrency, price, amount) {
  var orderkey = Exchange.getOrderKey({from:eth.accounts[0], gas:50000});
  Exchange.createLimitOrder(account, orderkey, giveCurrency, getCurrency, price, amount, {from:eth.accounts[0], gas:1000000});
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

  buyOrderKey = Exchange.buy_tail(); //highest buy price orderkey
  sellOrderKey = Exchange.sell_head(); //lowest sel price order key 

  buyPrice = Number(Exchange.getPrice(buyOrderKey));
  sellPrice = Number(Exchange.getPrice(sellOrderKey));

  while (buyPrice >= sellPrice && Exchange.sizes()[1] > 0 && Exchange.sizes()[2] > 0) { //buy Length and sell length both greater than 0

    buyAmount = Number(Exchange.getAmount(buyOrderKey));
    buyAccount = Exchange.getAccount(buyOrderKey);

    sellAmount = Number(Exchange.getAmount(sellOrderKey));
    sellAccount = Exchange.getAccount(sellOrderKey);

    if (buyAmount > sellAmount) {
      deposit(buyAccount, "BitCoin", sellAmount); 
      withdraw(buyAccount, "USD", sellAmount * buyPrice);
      deposit(sellAccount, "USD", sellAmount * buyPrice);
      withdraw(sellAccount, "BitCoin", sellAmount);
      
      Exchange.setAmount(buyOrder, buyAmount - sellAmount, {from:eth.accounts[0], gas:50000});
      Exchange.setAmount(sellOrder, 0, {from:eth.accounts[0], gas:50000});
      Exchange.partiallyFilled(buyOrderKey, {from:eth.accounts[0], gas:50000});

      nextSellOrderKey = Exchange.getNext(sellOrderKey);
      Exchange.putSettle(sellOrderKey, {from: eth.accounts[0], gas:500000});

      sellOrderKey = nextSellOrderKey;
      sellPrice = Number(Exchange.getPrice(sellOrderKey));

      mine();
      settledOrderCount += 1; 
      console.log('1 order settled');

    } else if (sellAmount > buyAmount) { 
      deposit(buyAccount, "BitCoin", buyAmount); 
      withdraw(buyAccount, "USD", buyAmount * buyPrice);
      deposit(sellAccount, "USD", buyAmount * buyPrice);
      withdraw(sellAccount, "BitCoin", buyAmount);
      
      Exchange.setAmount(buyOrder, 0, {from:eth.accounts[0], gas:50000});
      Exchange.setAmount(sellOrder, sellAmount - buyAmount, {from:eth.accounts[0], gas:50000});
      Exchange.partiallyFilled(sellOrderKey, {from:eth.accounts[0], gas:50000});
      
      prevBuyOrderKey = Exchange.getPrev(buyOrderKey);
      Exchange.putSettle(buyOrderKey, {from: eth.accounts[0], gas:500000});
      buyOrderKey = prevBuyOrderKey;
      sellOrderKey = nextSellOrderKey;
      buyPrice = Number(Exchange.getPrice(buyOrderKey));

      mine();
      settledOrderCount += 1;
      console.log('1 order settled');

    } else if (sellAmount == buyAmount) {
      deposit(buyAccount, "BitCoin", sellAmount); 
      withdraw(buyAccount, "USD", sellAmount * buyPrice);
      deposit(sellAccount, "USD", sellAmount * buyPrice);
      withdraw(sellAccount, "BitCoin", sellAmount);
      
      Exchange.setAmount(buyOrder, 0, {from:eth.accounts[0], gas:50000});
      Exchange.setAmount(sellOrder, 0, {from:eth.accounts[0], gas:50000});
      
      prevBuyOrderKey = Exchange.getPrev(buyOrderKey);
      nextSellOrderKey = Exchange.getNext(sellOrderKey);
      Exchange.putSettle(buyOrderKey, {from: eth.accounts[0], gas:500000});
      Exchange.putSettle(sellOrderKey, {from: eth.accounts[0], gas:500000});
      buyOrderKey = prevBuyOrderKey; 
      sellOrderKey = nextSellOrderKey;
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
  Exchange.deposit(account, currencyName, amount, {from:eth.accounts[0], gas:50000});  
}

function withdraw(account, currencyName, amount) {
  Exchange.withdraw(account, currencyName, amount, {from:eth.accounts[0], gas:50000});
}

function getBalance(account, currencyName) {
  Exchange.getBalance(account, currencyName);
}

function getOrderInfo(orderKey) {
  var account = Exchange.getAccount(orderKey);
  var giveCurrency = Exchange.giveCurrency(orderKey);
  var getCurrency = Exchange.getCurrency(orderKey);
  var price = Exchange.getPrice(orderKey);
  var amount = Exchange.getAmount(orderKey); 
  var status; 
  switch (Exchange.getStatus(orderKey)) {
    case 0: 
      status = "open";
      break;
    case 1: 
      status = "partially filled";
      break;
    case 2:
      status = "settled";
      break;
    case 3:
      status = "cancelled";
  }
  return [account, giveCurrency, getCurrency, price, amount, status];
}

function displayAllOpenOrders() {
//buyOrders 
  var buyLength = Exchange.buy_length();
  var i;
  var buyOrderKey = Exchange.buy_tail(); //from highest
  var buyOrder;
  var orderPrice; 
  var orderAmount;
  console.log("Buy Orders");
  for (i = 0; i < buyLength; i++) {
    buyOrder = getOrderInfo(buyOrderKey);
    orderPrice = Number(buyOrder[3]);
    orderAmount = Number(buyOrder[4]);

    console.log(orderPrice, " ", orderAmount);
    buyOrderKey = Exchange.getPrev(buyOrderKey);
  }

//sellOrders
  var sellLength = Exchange.sell_length();
  var sellOrderKey = Exchange.sell_head(); //from lowest
  for (i = 0; i < sellLength; i++) {
    sellOrder = getOrderInfo(sellOrderKey);
    orderPrice = Number(sellOrder[3]);
    orderAmount = Number(sellOrder[4]);

    console.log(orderPrice, " ", orderAmount);
    sellOrderKey = Exchang.getNext(sellOrderKey);
  }
}

function displayAccountOrders(account) {
  var length = Exchange.accountOrderLength(account);
  var i;
  var orderType;
  var orderPrice;
  var orderAmount;
  var orderStatus;
  console.log("Order Type" + " Price " + " Amount " + " Status ");
  for (i = 0; i < length; i++) {
    accountOrder = getOrderInfo(Exchange.accountOrder(account, i));
    if (accountOrder[1] == "USD") //giveCurrency is USD
      orderType = "Buy";
    else if (accountOrder == "BitCoin")
      orderType = "Sell";
    
    orderPrice = Number(accountOrder[3]);
    orderAmount = Number(accountOrder[4]);
    orderStatus = accountOrder[5];
    console.log(orderType , " " , orderPrice , " " , orderAmount , " " , orderStatus);
  }
}

