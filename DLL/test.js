var contract = artifacts.require("./sanDoublyLinkedList");

var contract_address = '0xf7b77801b74034c3dbad4ee20362e84f8d43ca4e';

module.exports = function() {
  function populate_list() {
    var ins =  contract.at(contract_address);  
    
    for (i = 0; i < 5; i++) { 
      ins.push_back(i.toString(), i.toString());
      console.log("Populating, Key: " + i.toString() + " Value: " + i.toString());
    }
  }

   function display_list() {
    var ins = contract.at(contract_address);
    var size = ins.getLength();
    console.log("list size: " + size);
    for (i = 0; i < size; i++) {
      console.log(ins.front());
      ins.pop_front();
    }
  }

  populate_list();
  display_list();
}

