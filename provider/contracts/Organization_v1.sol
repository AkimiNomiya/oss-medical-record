pragma solidity ^0.4.8;

import '../../gmo/contracts/VersionContract.sol';
import './Organization.sol';
import './OrganizationLogic_v1.sol';

contract Organization_v1 is VersionContract, Organization {
    OrganizationLogic_v1 public logic_v1;
    uint constant TIMESTAMP_RANGE = 600;

    function Organization_v1(ContractNameService _cns, OrganizationLogic_v1 _logic) VersionContract(_cns, CONTRACT_NAME) {logic_v1 = _logic;}

    function create(bytes _sign, uint _timestamp, bytes32 _id, address _initAddr, bytes32 _name) {
        if(!checkTimestamp(_timestamp)) throw;

        bytes32 hash = calcEnvHash('create');
        hash = sha3(hash, _timestamp);
        hash = sha3(hash, _id);
        hash = sha3(hash, _initAddr);
        hash = sha3(hash, _name);
        address from = recoverAddress(hash, _sign);

        logic_v1.create(from, _id, _initAddr, _name);
    }

    function remove(bytes _sign, uint _timestamp, bytes32 _id) {
        if(!checkTimestamp(_timestamp)) throw;

        bytes32 hash = calcEnvHash('remove');
        hash = sha3(hash, _timestamp);
        hash = sha3(hash, _id);
        address from = recoverAddress(hash, _sign);

        logic_v1.remove(from, _id);
    }

    /* admin management */

    function addController(bytes _sign, uint _timestamp, bytes32 _id, address _controllerAddr) {
        if(!checkTimestamp(_timestamp)) throw;

        bytes32 hash = calcEnvHash('addController');
        hash = sha3(hash, _timestamp);
        hash = sha3(hash, _id);
        hash = sha3(hash, _controllerAddr);
        address from = recoverAddress(hash, _sign);

        logic_v1.addController(from, _id, _controllerAddr);
    }

    function removeController(bytes _sign, uint _timestamp, bytes32 _id, address _controllerAddr) {
        if(!checkTimestamp(_timestamp)) throw;

        bytes32 hash = calcEnvHash('removeController');
        hash = sha3(hash, _timestamp);
        hash = sha3(hash, _id);
        hash = sha3(hash, _controllerAddr);
        address from = recoverAddress(hash, _sign);

        logic_v1.removeController(from, _id, _controllerAddr);
    }

    /* member management */

    function addMember(bytes _sign, uint _timestamp, bytes32 _id, address _doctorAddr) {
        if(!checkTimestamp(_timestamp)) throw;

        bytes32 hash = calcEnvHash('addMember');
        hash = sha3(hash, _timestamp);
        hash = sha3(hash, _id);
        hash = sha3(hash, _doctorAddr);
        address from = recoverAddress(hash, _sign);

        logic_v1.addMember(from, _id, _doctorAddr);
    }

    function removeMember(bytes _sign, uint _timestamp, bytes32 _id, address _doctorAddr) {
        if(!checkTimestamp(_timestamp)) throw;

        bytes32 hash = calcEnvHash('removeMember');
        hash = sha3(hash, _timestamp);
        hash = sha3(hash, _id);
        hash = sha3(hash, _doctorAddr);
        address from = recoverAddress(hash, _sign);

        logic_v1.removeMember(from, _id, _doctorAddr);
    }

    function isController(bytes32 _OrganizationId, address _addr) constant returns (bool) {
        return logic_v1.isController(_OrganizationId, _addr);
    }

    function isMember(bytes32 _OrganizationId, address _addr) constant returns (bool) {
        return logic_v1.isMember(_OrganizationId, _addr);
    }

    /* simple getter */

    function getName(bytes32 _id) constant returns (bytes32) {
        return logic_v1.getName(_id);
    }

    function getMemberGroupId(bytes32 _id) constant returns (bytes32) {
        return logic_v1.getMemberGroupId(_id);
    }

    /* ----------- privete functions ----------------- */

    function checkTimestamp(uint _timestamp) private constant returns (bool) {
        return (now - TIMESTAMP_RANGE < _timestamp && _timestamp < now + TIMESTAMP_RANGE);
    }


}
