var DLL; 

function listAccounts() 
{
  for (i = 0; i < eth.accounts.length; i++) {
    console.log(eth.accounts[i]);
  }
}

function mine() 
{
  miner.start(1);
  admin.sleepBlocks(1);
  miner.stop();
}

function set_DLL_address(addr) {
  DLL = eth.contract([{"constant":true,"inputs":[],"name":"sorted_tail","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"tail","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"length","outputs":[{"name":"","type":"int256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"pop_front","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"key","type":"string"},{"name":"value","type":"string"},{"name":"targetkey","type":"string"}],"name":"insert","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_a","type":"string"},{"name":"_b","type":"string"}],"name":"compare","outputs":[{"name":"","type":"int256"}],"payable":false,"stateMutability":"pure","type":"function"},{"constant":false,"inputs":[],"name":"clear","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"pop_back","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"targetkey","type":"string"}],"name":"remove","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"getSortedHead","outputs":[{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"back","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"head","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"size","outputs":[{"name":"","type":"int256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"key","type":"string"}],"name":"getEntry","outputs":[{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"front","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"sorted_head","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"}]).at(addr);
}

function iterate() 
{
  var key = DLL.sorted_head();	
  for (e = DLL.getEntry(key); e[0].length != 0; e = DLL.getEntry(e[5])) {
    console.log(e[0], e[1], e[2], e[3], e[4], e[5]);
  }
}

function unlock() 
{
  for(i = 0; i < eth.accounts.length; i++) {
    personal.unlockAccount(eth.accounts[i], "1", 3600);
  } 
}

function testPopulate() {
  DLL.insert("1", "1", "1", {from:eth.accounts[0], gas:1000000});
  DLL.insert("3", "3", "3", {from:eth.accounts[0], gas:1000000});
}

function getTargetKey(key) { //linear search done outside 
  e = DLL.getEntry(DLL.sorted_head());
  while (key >= e[0] && e[0] != DLL.sorted_tail()) {
    e = DLL.getEntry(e[5]);
  }
   return e[0];
}

function insert(key, value) { //find the way to do mining asynchronously
  targetkey = getTargetKey(key);
  DLL.insert(key, value, targetkey, {from:eth.accounts[0], gas:1000000});
  return targetkey;
}

function remove(targetkey) { 
  return DLL.remove(targetkey, {from:eth.accounts[0], gas:1000000});
}
