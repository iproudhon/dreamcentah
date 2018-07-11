
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
  var key = DLL.head();	
  for (e = DLL.getEntry(key); e[0].length != 0; e = DLL.getEntry(e[3])) {
    for(i = 0; i<5; i++) {
      if(e[i] == "") {
         e[i] = " ";
      }
    }
    console.log(e[0], e[1], e[2], e[3], e[4], e[5]);
  }
}

function iterate_reverse()
{
  var key = DLL.tail();	
  for (e = DLL.getEntry(key); e[0].length != 0; e = DLL.getEntry(e[2])) {
    for(i = 0; i<5; i++) {
      if(e[i] == "") {
         e[i] = " ";
      }
    }
    console.log(e[0], e[1], e[2], e[3], e[4], e[5]);
  }
}

function sorted_iterate() 
{
  var key = DLL.sorted_head();	
  for (e = DLL.getEntry(key); e[0].length != 0; e = DLL.getEntry(e[5])) {
    for(i = 0; i<5; i++) {
      if(e[i] == "") {
         e[i] = " ";
      }
    }
    console.log(e[0], e[1], e[2], e[3], e[4], e[5]);
  }
}

function sorted_iterate_reverse()
{
  var key = DLL.sorted_tail();
  for (e = DLL.getEntry(key); e[0].length != 0; e = DLL.getEntry(e[4])) {
    for(i = 0; i<5; i++) {
      if(e[i] == "") {
         e[i] = " ";
      }
    }
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
  DLL.insert("1", "1", "1", {from:eth.accounts[0], gas:1000000});
  DLL.insert("2", "2", "2", {from:eth.accounts[0], gas:1000000});
  DLL.insert("3", "3", "3", {from:eth.accounts[0], gas:1000000});
}

function getTargetKey(key) { //linear search done outside returns index before, "" if it is at front
  e = DLL.getSortedHead();
 
  if(key <= e[0]) {
    return "";
  }
  
  a = DLL.sorted_tail();
  if(key >= a) {
    return a;
  }
  
  while (key >= e[0] && e[0] != DLL.sorted_tail()) {
    e = DLL.getEntry(e[5]);
  }
  return e[4];
}

function insert(key, value, update) { //find the way to do mining asynchronously
  if(key == ""){
    return 0; 
  }
  
  if(DLL.head() == "") {
    DLL.insert(key, value, "0", update, {from:eth.accounts[0], gas:1000000});
    return 1;
  }
  
  targetkey = getTargetKey(key);
  DLL.insert(key, value, targetkey, update, {from:eth.accounts[0], gas:1000000});
  return 2;
}

function remove(targetkey) { 
  return DLL.remove(targetkey, {from:eth.accounts[0], gas:1000000});
}

function clear() {
  return DLL.clear({from:eth.accounts[0], gas:1000000});
}

function pop_back() {
  return DLL.pop_back({from:eth.accounts[0], gas:1000000});
}

function pop_front() {
  return DLL.pop_front({from:eth.accounts[0], gas:1000000});
}
