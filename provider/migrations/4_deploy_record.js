const config = require('../config.json'),
    AddressGroup_v1 = artifacts.require('./AddressGroup_v1.sol'),
    ContractNameService = artifacts.require('./ContractNameService.sol'),
    Record_v1 = artifacts.require('./Record_v1.sol'),
    RecordLogic_v1 = artifacts.require('./RecordLogic_v1.sol'),
    RecordField_v1 = artifacts.require('./RecordField_v1.sol'),
    RecordEvent_v1 = artifacts.require('./RecordEvent_v1.sol');

module.exports = function(deployer) {
    return deployer.deploy(RecordEvent_v1, ContractNameService.address).then(function() {
        return deployer.deploy(RecordField_v1, ContractNameService.address);
    }).then(function() {
        return deployer.deploy(RecordLogic_v1, ContractNameService.address, RecordField_v1.address, RecordEvent_v1.address, config.adminGroupId, config.gmoCns);
    }).then(function() {
        return deployer.deploy(Record_v1, ContractNameService.address, RecordLogic_v1.address);
    }).then(function() {
        return ContractNameService.deployed();
    }).then(function(instance) {
        return instance.setContract('Record', 1, Record_v1.address, RecordLogic_v1.address);
    });
}
