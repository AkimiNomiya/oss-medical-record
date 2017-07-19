const config = require('../config.json'),
    ContractNameService = artifacts.require('./ContractNameService.sol'),
    Organization_v1 = artifacts.require('./Organization_v1.sol'),
    OrganizationLogic_v1 = artifacts.require('./OrganizationLogic_v1.sol'),
    OrganizationField_v1 = artifacts.require('./OrganizationField_v1.sol'),
    OrganizationEvent_v1 = artifacts.require('./OrganizationEvent_v1.sol');

module.exports = function(deployer) {
    deployer.deploy(OrganizationEvent_v1, ContractNameService.address).then(function() {
        return deployer.deploy(OrganizationField_v1, ContractNameService.address);
    }).then(function() {
        return deployer.deploy(OrganizationLogic_v1, ContractNameService.address, OrganizationField_v1.address, OrganizationEvent_v1.address, config.adminGroupId, config.gmoCns);
    }).then(function() {
        return deployer.deploy(Organization_v1, ContractNameService.address, OrganizationLogic_v1.address);
    }).then(function() {
        return ContractNameService.deployed();
    }).then(function(instance) {
        return instance.setContract('Organization', 1, Organization_v1.address, OrganizationLogic_v1.address);
    });
}
