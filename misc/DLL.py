import web3 
import json 
import threading 
import sys
import time

from web3 import Web3
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
    key = reader.head()
    e = reader.getEntry(key)
    while len(e[0]) != 0:
        print(e[0], e[1], e[2], e[3], e[4], e[5])
        e = reader.getEntry(e[3])

def iterateReverse():
    key = reader.tail()
    e = reader.getEntry(key)
    while len(e[0]) != 0:
        print(e[0], e[1], e[2], e[3], e[4], e[5])
        e = reader.getEntry(e[2])

def sortedIterate():
    key = reader.sorted_head()
    e = reader.getEntry(key)
    while len(e[0]) != 0:
        print(e[0], e[1], e[2], e[3], e[4], e[5])
        e = reader.getEntry(e[5])

def sortedIterateReverse():
    key = reader.sorted_tail()
    e = reader.getEntry(key)
    while len(e[0]) != 0:
        print(e[0], e[1], e[2], e[3], e[4], e[5])
        e = reader.getEntry(e[4])

def testPopulate():
    for i in range(10):
        latest_tx_hash = contract_instance.functions.insert(str(i), str(i), str(i)).transact()
    return True 

def getTargetKey(key):
    e = reader.getSortedHead()
    while key >= e[0] and e[0] != reader.sorted_tail():
        e = reader.getEntry(e[5])
    return e

def insert(key, value): 
    if reader.head() == 'NULL': #question: what should the targetkey be? 
        tx_hash = contract_instance.functions.insert(key, value, "0").transact()
    elif key > reader.sorted_tail() or key < reader.sorted_head():
        tx_hash = contract_instance.functions.insert(key, value, "0").transact()
    else: 
        targetkey = getTargetKey(key)
        tx_hash = contract_instance.functions.insert(key, value, targetkey).transact()
    print(str(tx_hash))

def remove(targetkey):
    tx_hash = contract_instance.functions.remove(targetkey).transact()
    return tx_hash

def main(): 
    
    function_call = sys.argv[1]
    if len(sys.argv) > 2: 
        parameters = sys.argv[2:]
    
    if function_call == 'insert':
        insert(parameters[0], parameters[1])
    elif function_call == 'remove':
        remove(parameters[0])
    elif function_call == 'iterate':
        iterate()
    elif function_call == 'testPopulate':
        testPopulate()
    elif function_call == 'iterateReverse':
        iterateReverse()
    elif function_call == 'sortedIterate':
        sortedIterate()
    elif function_call == 'sortedIterateReverse':
        sortedIterateReverse()
    elif function_call == 'getTargetKey':
        getTargetKey()
    else:
        print('Error: ' + function_call + ' function not found')
        print('Usage: DLL.py <function name> <parameter1, parameter2...>') 
        print('No need to put quotation mark around parameters')
if __name__ == '__main__':
    main()