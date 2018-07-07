

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