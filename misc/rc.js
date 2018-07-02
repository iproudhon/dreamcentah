

function listAccounts() {
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
  i = linkedLists.front();
  if (i == null)
    return;
  while (i != null)
  {
    j = linkedLists.getEntry(i);
    console.log(j.key, ", ", j.value, ", ");
    i = j.next;
  }
}
