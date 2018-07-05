var sanlist = artifacts.require("./sanDoublyLinkedList.sol");
var stringUtils = artifacts.require("./stringUtils.sol");

module.exports = function(deployer) {
  deployer.deploy(sanlist);
  deployer.link(stringUtils, sanlist);
};
