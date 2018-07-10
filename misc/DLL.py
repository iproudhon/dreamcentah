import web3 
import json 
import threading 
import sys
import time


#mining function to be implemented, execution from the terminal to be implemented 

from web3 import Web3
from web3.miner import Miner
from web3.contract import ConciseContract 

#get abi and bin(contract_data) from compiler 
abi = '[{"constant":true,"inputs":[],"name":"sorted_tail","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"tail","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"length","outputs":[{"name":"","type":"int256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"pop_front","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"key","type":"string"},{"name":"value","type":"string"},{"name":"targetkey","type":"string"}],"name":"insert","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_a","type":"string"},{"name":"_b","type":"string"}],"name":"compare","outputs":[{"name":"","type":"int256"}],"payable":false,"stateMutability":"pure","type":"function"},{"constant":false,"inputs":[],"name":"clear","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"pop_back","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"targetkey","type":"string"}],"name":"remove","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"getSortedHead","outputs":[{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"back","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"head","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"size","outputs":[{"name":"","type":"int256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"key","type":"string"}],"name":"getEntry","outputs":[{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"},{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"front","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"sorted_head","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"}]'
contract_address = '0x0da924c71438fadfd29aac4f85c7162ca6613361' #your contract_address
contract_address = Web3.toChecksumAddress(contract_address)

w3 = Web3() #automatically connects to IPC provider.  
    
contract_instance = w3.eth.contract(abi=abi, address=contract_address, )
reader = ConciseContract(contract_instance)
w3.eth.defaultAccount = w3.eth.accounts[0]

write_function_count = 0
latest_tx_hash = None

def iterate():
    read()
    key = reader.head()
    e = reader.getEntry(key)
    while len(e[0]) != 0:
        print(e[0], e[1], e[2], e[3], e[4], e[5])
        e = reader.getEntry(e[3])

def iterateReverse():
    read()
    key = reader.tail()
    e = reader.getEntry(key)
    while len(e[0]) != 0:
        print(e[0], e[1], e[2], e[3], e[4], e[5])
        e = reader.getEntry(e[2])

def sortedIterate():
    read()
    key = reader.sorted_head()
    e = reader.getEntry(key)
    while len(e[0]) != 0:
        print(e[0], e[1], e[2], e[3], e[4], e[5])
        e = reader.getEntry(e[5])

def sortedIterateReverse():
    read()
    key = reader.sorted_tail()
    e = reader.getEntry(key)
    while len(e[0]) != 0:
        print(e[0], e[1], e[2], e[3], e[4], e[5])
        e = reader.getEntry(e[4])

def testPopulate():
    global latest_tx_hash
    for i in range(10):
        write()
        latest_tx_hash = contract_instance.functions.insert(str(i), str(i), str(i)).transact()
    return True 

def getTargetKey(key):
    e = reader.getEntry(reader.sorted_head())
    while key >= e[0] and e[0] != reader.sorted_tail():
        e = reader.getEntry(e[5])
    return e

def insert(key, value): 
    write()
    global latest_tx_hash
    if reader.head() == 'NULL':
        latest_tx_hash = contract_instance.functions.insert(key, value, "0").transact()
        return 0
    elif key > reader.sorted_tail() or key < reader.sorted_head():
        latest_tx_hash = contract_instance.functions.insert(key, value, "0").transact()
        return 1
    else: 
        targetkey = getTargetKey(key)
        latest_tx_hash = contract_instance.functions.insert(key, value, targetkey).transact()
    return 2

def update(key, value):
    write() 
    global latest_tx_hash
    latest_tx_hash = contract_instance.functions.update(key, value).transact()
    return latest_tx_hash

def remove(targetkey):
    write() 
    global latest_tx_hash
    latest_tx_hash = contract_instance.functions.remove(targetkey).transact()
    return latest_tx_hash

def clear():
    write() 
    global latest_tx_hash
    latest_tx_hash = contract_instance.functions.clear().transact()
    return latest_tx_hash

def pop_back():
    write()
    return 

def write():
    global write_function_count
    global latest_tx_hash
    if write_function_count == 10: 
        wait_for_receipt(w3, latest_tx_hash, 1) 
    write_function_count += 1 

def read():
    global latest_tx_hash
    if latest_tx_hash != None: 
        wait_for_receipt(w3, latest_tx_hash, 1)

def wait_for_receipt(w3, tx_hash, poll_interval):
    while True:
        tx_receipt = w3.eth.getTransactionReceipt(tx_hash)
        if tx_receipt: 
            return tx_receipt
        time.sleep(poll_interval)



    



