var DLL_instance; 

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

function set_DLL_instance_address(addr) {
  DLL_instance = eth.contract([{"constant":true,"inputs":[],"name":"sorted_tail","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"tail","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"length","outputs":[{"name":"","type":"int256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"pop_front","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"key","type":"string"},{"name":"value","type":"string"},{"name":"targetkey","type":"string"}],"name":"insert","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_a","type":"string"},{"name":"_b","type":"string"}],"name":"compare","outputs":[{"name":"","type":"int256"}],"payable":false,"stateMutability":"pure","type":"function"},{"constant":false,"inputs":[],"name":"clear","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"pop_back","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"targetkey","type":"string"}],"name":"remove","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"getSortedHead","outputs":[{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"back","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"head","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"size","outputs":[{"name":"","type":"int256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"key","type":"string"}],"name":"getEntry","outputs":[{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"front","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"sorted_head","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"}]).at(addr);
}

function iterate()
{
  var key = DLL_instance.head();	
  for (e = DLL_instance.getEntry(key); e[0].length != 0; e = DLL_instance.getEntry(e[3])) {
    console.log(e[0], e[1], e[2], e[3], e[4], e[5]);
  }
}

function iterate_reverse()
{
  var key = DLL_instance.tail();	
  for (e = DLL_instance.getEntry(key); e[0].length != 0; e = DLL_instance.getEntry(e[2])) {
    console.log(e[0], e[1], e[2], e[3], e[4], e[5]);
  }
}

function sorted_iterate() 
{
  var key = DLL_instance.sorted_head();	
  for (e = DLL_instance.getEntry(key); e[0].length != 0; e = DLL_instance.getEntry(e[5])) {
    console.log(e[0], e[1], e[2], e[3], e[4], e[5]);
  }
}

function sorted_iterate_reverse()
{
  var key = DLL_instance.sorted_tail();
  for (e = DLL_instance.getEntry(key); e[0].length != 0; e = DLL_instance.getEntry(e[4])) {
    console.log(e[0], e[1], e[2], e[3], e[4], e[5]); 
  }
}

function unlock() 
{
  for(i = 0; i < eth.accounts.length; i++) {
    personal.unlockAccount(eth.accounts[i], "1", 36000);
  } 
}

function testPopulate() {
  DLL_instance.insert("1", "1", "1", {from:eth.accounts[0], gas:1000000});
  DLL_instance.insert("2", "2", "2", {from:eth.accounts[0], gas:1000000});
  DLL_instance.insert("3", "3", "3", {from:eth.accounts[0], gas:1000000});
}

function getTargetKey(key) { //linear search done outside 
  e = DLL_instance.getEntry(DLL_instance.sorted_head());
  while (key >= e[0] && e[0] != DLL_instance.sorted_tail()) {
    e = DLL_instance.getEntry(e[5]);
  }
   return e[0];
}

function update(key, value) { 
  return DLL_instance.update(key, value, {from:eth.accounts[0], gas:1000000});
}

function insert(key, value) { //find the way to do mining asynchronously
  if(DLL_instance.head() == "NULL") {
    DLL_instance.insert(key, value, "0", {from:eth.accounts[0], gas:1000000});
    return 0;
  }
  
  if(key > DLL_instance.sorted_tail() || key < DLL_instance.sorted_head()) {
    DLL_instance.insert(key, value, "0", {from:eth.accounts[0], gas:1000000});
    return 1;
  }
  
  targetkey = getTargetKey(key);
  DLL_instance.insert(key, value, targetkey, {from:eth.accounts[0], gas:1000000});
  return 2;
}

function remove(targetkey) { 
  return DLL_instance.remove(targetkey, {from:eth.accounts[0], gas:1000000});
}

function clear() {
  return DLL_instance.clear({from:eth.accounts[0], gas:1000000});
}

function pop_back() {
  return DLL_instance.pop_back({from:eth.accounts[0], gas:1000000});
}

function pop_front() {
  return DLL_instance.pop_front({from:eth.accounts[0], gas:1000000});
}
