const config = require('../config.json'),
    ContractNameService = artifacts.require('./ContractNameService.sol'),
    History_v1 = artifacts.require('./History_v1.sol'),
    HistoryLogic_v1 = artifacts.require('./HistoryLogic_v1.sol'),
    HistoryField_v1 = artifacts.require('./HistoryField_v1.sol'),
    HistoryEvent_v1 = artifacts.require('./HistoryEvent_v1.sol');


module.exports = function(deployer) {
    return deployer.deploy(HistoryEvent_v1, ContractNameService.address).then(function() {
        return deployer.deploy(HistoryField_v1, ContractNameService.address);
    }).then(function() {
        return deployer.deploy(HistoryLogic_v1, ContractNameService.address, HistoryField_v1.address, HistoryEvent_v1.address, config.adminGroupId, config.gmoCns);
    }).then(function() {
        return deployer.deploy(History_v1, ContractNameService.address, HistoryLogic_v1.address);
    }).then(function() {
        return ContractNameService.deployed();
    }).then(function(instance) {
        return instance.setContract('History', 1, History_v1.address, HistoryLogic_v1.address);
    });
}
