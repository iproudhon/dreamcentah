var shead = "";
var stail = "";
var size = 0;
var sortedmap = [];

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
    for(i = 0; i<=5; i++) {
      if(e[i] == "") {
         e[i] = " "; //just for readability null is a " "
      }
    }
    console.log("|", e[0],"|", e[1], "|", e[2],"|", e[3],"|", e[4],"|", e[5], "|");
  }
}

function iterate_reverse()
{
  var key = DLL.tail();	
  for (e = DLL.getEntry(key); e[0].length != 0; e = DLL.getEntry(e[2])) {
    for(i = 0; i<=5; i++) {
      if(e[i] == "") {
         e[i] = " ";
      }
    }
    console.log("|", e[0],"|", e[1], "|", e[2],"|", e[3],"|", e[4],"|", e[5], "|");
  }
}

function sorted_iterate() 
{
  var key = DLL.sorted_head();	
  for (e = DLL.getEntry(key); e[0].length != 0; e = DLL.getEntry(e[5])) {
    for(i = 0; i<=5; i++) {
      if(e[i] == "") {
         e[i] = " ";
      }
    }
    console.log("|", e[0],"|", e[1],"|", e[2],"|", e[3],"|", e[4],"|", e[5], "|");
  }
}

function sorted_iterate_reverse()
{
  var key = DLL.sorted_tail();
  for (e = DLL.getEntry(key); e[0].length != 0; e = DLL.getEntry(e[4])) {
    for(i = 0; i<=5; i++) {
      if(e[i] == "") {
         e[i] = " ";
      }
    }
    console.log("|", e[0],"|", e[1], "|", e[2],"|", e[3],"|", e[4],"|", e[5], "|"); 
  }
}

function unlock() 
{
  for(i = 0; i < eth.accounts.length; i++) {
    personal.unlockAccount(eth.accounts[i], "1", 36000);
  } 
}

function testPopulate() {
  DLL.insert("1", "1", "", false, {from:eth.accounts[0], gas:1000000});
  DLL.insert("2", "2", "1", false, {from:eth.accounts[0], gas:1000000});
  DLL.insert("3", "3", "2", false, {from:eth.accounts[0], gas:1000000});
  shead = "1";
  stail = "3";
  size = size+3;
}

function getTargetKey(key) { //linear search done outside returns index before, "" if it is at front
  if(size == 0) {
    return;
  }

  e = DLL.getEntry(shead);
  
  if(key < shead) {
    return "";
  }
  
  if(key > stail) {
    return stail;
  }
  
  index = 1;
  while(key > sortedmap[index]) {
    index++;
  }
  return sortedmap[index-1];
  
 // while (key >= e[0] && e[0] != stail) {
 //   e = DLL.getEntry(e[5]);
 // }
 // return e[4];
}

function insert(key, value, update) {
  if(key == ""){
    return 0; 
  }
  
  if(size == 0) {
    shead = key;
    stail = key;
    DLL.insert(key, value, "", update, {from:eth.accounts[0], gas:1000000});
    sortedmap.push(key);
    size++;
    return 1;
  }
  
  targetkey = getTargetKey(key);
  DLL.insert(key, value, targetkey, update, {from:eth.accounts[0], gas:1000000});
 
  if(key < shead) {
    shead = key;
    sortedmap.splice(0,0,key);
  }
  
  else if(key > stail) {
    stail = key;
    sortedmap.push(key);
  }
  
  else{
    index = 1;
    while(key > sortedmap[index]) {
      index++;
    }
    sortedmap.splice(index,0,key);
  }
  
  size++;
  return 2;
}

function remove(targetkey) { 

  if(size == 1) {
    stail = "";
    shead = "";
    sortedmap.pop();
  }
  
  else if(targetkey == stail) {
    i = DLL.getEntry(targetkey);
    stail = i[4];
    sortedmap.pop();
  }
    
  else if(targetkey == shead) {
    j = DLL.getEntry(targetkey);
    shead = j[5];
    sortedmap.splice(0,1);
  }
  
  else {
    index = 1;
    while(index < sortedmap.length) {
      if(sortedmap[index] == targetkey) {
        sortedmap.splice(index,1);
        break;
      }
      index++;
    }
  }
  
  size--;
  return DLL.remove(targetkey, {from:eth.accounts[0], gas:1000000});
}

