
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
  var buyOrder = Exchange.buy_tail();
  var sellOrder = Exchange.sell_head();
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

      nextSellOrderKey = Exchange.getNextKey(sellOrderKey);
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
      
      prevBuyOrderKey = Exchange.getPrevKey(buyOrderKey);
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
      
      prevBuyOrderKey = Exchange.getPrevKey(buyOrderKey);
      nextSellOrderKey = Exchange.getNextKey(sellOrderKey);
      Exchange.putSettle(buyOrderKey, {from: eth.accounts[0], gas:500000});
      Exchange.putSettle(sellOrderKey, {from: eth.accounts[0], gas:500000});
      buyOrderKey = prevBuyOrderKey; 
      sellOrderKey = nextSellOrderKey;
      buyPrice = Number(Exchange.getPrice(buyOrderKey));
      sellPrice = Number(Exchange.getPrice(sellOrderKey));
      
      mine();
      settledOrderCount += 2;
      console.log('2 orders settled');
      break;
    }
    console.log('In loop');
  }
  console.log('Settled orders: ' + settledOrderCount);
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
  return (account, giveCurrency, getCurrency, price, amount, status);
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
