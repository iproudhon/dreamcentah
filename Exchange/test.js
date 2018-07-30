function initiateAccounts() {
  Exchange.deposit(eth.accounts[0], 'USD', 10000, {from:eth.accounts[0], gas:32500});
  Exchange.deposit(eth.accounts[1], 'USD', 10000, {from:eth.accounts[0], gas:32500});
  Exchange.deposit(eth.accounts[2], 'USD', 10000, {from:eth.accounts[0], gas:32500});
  Exchange.deposit(eth.accounts[3], 'USD', 10000, {from:eth.accounts[0], gas:32500});
  Exchange.deposit(eth.accounts[0], 'BitCoin', 10000, {from:eth.accounts[0], gas:32500});
  Exchange.deposit(eth.accounts[1], 'BitCoin', 10000, {from:eth.accounts[0], gas:32500});
  Exchange.deposit(eth.accounts[2], 'BitCoin', 10000, {from:eth.accounts[0], gas:32500});
  Exchange.deposit(eth.accounts[3], 'BitCoin', 10000, {from:eth.accounts[0], gas:32500});
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

function testOrders() {
  showBalance();
  createLimitOrder(eth.accounts[0], 'USD', 'BitCoin', 1000, 1);
  createLimitOrder(eth.accounts[1], 'BitCoin', 'USD', 1000, 1);
  mine();
  settle();
  console.log('after settling');
  showBalance();
}

function createLimitOrder(account, giveCurrency, getCurrency, price, amount) {
  var orderkey = Exchange.getOrderkey({from:eth.accounts[0], gas:32500});
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

  buyPrice = getPrice(buyOrderKey);
  sellPrice = getPrice(sellOrderKey);

  if (buyPrice >= sellPrice) { //condition for any settle function to happen
    while (buyPrice >= sellPrice) {

      buyAmount = getAmount(buyOrderKey);
      buyAccount = getAccount(buyOrderKey);

      sellAmount = getAmount(sellOrderKey);
      sellAccount = getAccount(sellOrderKey);

      if (buyAmount > sellAmount) {
        Exchange.deposit(buyAccount, "BitCoin", sellAmount, {from:eth.accounts[0], gas:32500}); 
        Exchange.withdraw(buyAccount, "USD", sellAmount * buyPrice, {from:eth.accounts[0], gas:32500});
        Exchange.deposit(sellAccount, "USD", sellAmount * buyPrice, {from:eth.accounts[0], gas:32500});
        Exchange.withdraw(sellAccount, "BitCoin", sellAmount, {from:eth.accounts[0], gas:32500});
        Exchange.setAmount(buyOrder, buyAmount - sellAmount, {from:eth.accounts[0], gas:32500});
        Exchange.setAmount(sellOrder, 0, {from:eth.accounts[0], gas:32500});
        Exchange.partiallyFilled(buyOrderKey, {from:eth.accounts[0], gas:32500});

        nextSellOrderKey = getNextKey(sellOrderKey);
        Exchange.putSettle(sellOrderKey, {from: eth.accounts[0], gas:32500});
        sellOrderKey = nextSellOrderKey;
        sellPrice = getPrice(sellOrderKey);

        mine();

        settledOrderCount += 1; 
      } else if (sellAmount > buyAmount) { 
        Exchange.deposit(buyAccount, "BitCoin", buyAmount, {from:eth.accounts[0], gas:32500}); 
        Exchange.withdraw(buyAccount, "USD", buyAmount * buyPrice, {from:eth.accounts[0], gas:32500});
        Exchange.deposit(sellAccount, "USD", buyAmount * buyPrice, {from:eth.accounts[0], gas:32500});
        Exchange.withdraw(sellAccount, "BitCoin", buyAmount, {from:eth.accounts[0], gas:32500});
        Exchange.setAmount(buyOrder, 0, {from:eth.accounts[0], gas:32500});
        Exchange.setAmount(sellOrder, sellAmount - buyAmount, {from:eth.accounts[0], gas:32500});
        Exchange.partiallyFilled(sellOrderKey, {from:eth.accounts[0], gas:32500});
        
        prevBuyOrderKey = getPrevKey(buyOrderKey);
        Exchange.putSettle(buyOrderKey, {from: eth.accounts[0], gas:32500});
        buyOrderKey = prevBuyOrderKey;
        sellOrderKey = nextSellOrderKey;
        buyPrice = getPrice(buyOrderKey);

        mine();

        settledOrderCount += 1;
      } else if (sellAmount == buyAmount) {
        Exchange.deposit(buyAccount, "BitCoin", sellAmount, {from:eth.accounts[0], gas:32500}); 
        Exchange.withdraw(buyAccount, "USD", sellAmount * buyPrice, {from:eth.accounts[0], gas:32500});
        Exchange.deposit(sellAccount, "USD", sellAmount * buyPrice, {from:eth.accounts[0], gas:32500});
        Exchange.withdraw(sellAccount, "BitCoin", sellAmount, {from:eth.accounts[0], gas:32500});
        Exchange.setAmount(buyOrder, 0, {from:eth.accounts[0], gas:32500});
        Exchange.setAmount(sellOrder, 0, {from:eth.accounts[0], gas:32500});
        
        prevBuyOrderKey = getPrevKey(buyOrderKey);
        nextSellOrderKey = getNextKey(sellOrderKey);
        Exchange.putSettle(buyOrderKey, {from: eth.accounts[0], gas:32500});
        Exchange.putSettle(sellOrderKey, {from: eth.accounts[0], gas:32500});
        buyOrderKey = prevBuyOrderKey; 
        sellOrderKey = nextSellOrderKey;
        buyPrice = getPrice(buyOrderKey);
        sellPrice = getPrice(sellOrderKey);
        
        mine();

        settledOrderCount += 2; 
        break;
      }
    }
    console.log('Settled orders: ' + settledOrderCount);
  }


  
}

