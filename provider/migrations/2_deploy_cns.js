const config = require('../config.json'),
    AddressGroup_v1 = artifacts.require('./AddressGroup_v1.sol'),
    ContractNameService = artifacts.require('./ContractNameService.sol');

module.exports = function(deployer, network, accounts) {
    deployer.deploy(ContractNameService).then(function() {
        return ContractNameService.at(config.gmoCns).getLatestContract('AddressGroup');
    }).then(function(gmoGroup) {
        return AddressGroup_v1.at(gmoGroup).create(config.adminGroupId, accounts[0], [config.adminAddress], 0, 0);
    });
}
