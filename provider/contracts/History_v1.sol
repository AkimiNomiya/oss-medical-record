pragma solidity ^0.4.8;

import '../../gmo/contracts/VersionContract.sol';
import './HistoryLogic_v1.sol';

contract History_v1 is VersionContract {
    HistoryLogic_v1 public logic_v1;
    uint constant TIMESTAMP_RANGE = 600;


    function History_v1(ContractNameService _cns, HistoryLogic_v1 _logic) VersionContract(_cns, 'History') { logic_v1 = _logic;}

    function create(bytes _sign, bytes32 _objectId, bytes32 _dataHash, uint _timestamp) {
        if(!checkTimestamp(_timestamp)) throw;

        bytes32 hash = calcEnvHash('create');
        hash = sha3(hash, _objectId);
        hash = sha3(hash, _dataHash);
        hash = sha3(hash, _timestamp);
        address account = recoverAddress(hash, _sign);

        logic_v1.create(account, _objectId, _dataHash);
    }

    function remove(bytes _sign, uint _timestamp) {
        if(!checkTimestamp(_timestamp)) throw;

        bytes32 hash = calcEnvHash('remove');
        hash = sha3(hash, _timestamp);
        address account = recoverAddress(hash, _sign);

        logic_v1.remove(bytes32(account));
    }

    /* acccess controll */

    function addAllowGroup(bytes _sign, uint _timestamp, bytes32  _organizationId) {
        if(!checkTimestamp(_timestamp)) throw;

        bytes32 hash = calcEnvHash('addAllowGroup');
        hash = sha3(hash, _timestamp);
        hash = sha3(hash, _organizationId);
        address account = recoverAddress(hash, _sign);

        logic_v1.addAllowGroup(bytes32(account), _organizationId);
    }

    function removeAllowGroup(bytes _sign, uint _timestamp, bytes32 _organizationId) {
        if(!checkTimestamp(_timestamp)) throw;

        bytes32 hash = calcEnvHash('removeAllowGroup');
        hash = sha3(hash, _timestamp);
        hash = sha3(hash, _organizationId);
        address account = recoverAddress(hash, _sign);

        logic_v1.removeAllowGroup(bytes32(account), _organizationId);
    }

    function isAllowGroup(bytes32 _organizationId, address _id) constant returns (bool) {
        return logic_v1.isAllowGroup(_organizationId, bytes32(_id));
    }

    function isAllowGroupMember(address _account, address _id) constant returns (bool) {
        return logic_v1.isAllowGroupMember(_account, bytes32(_id));
    }

    function getAllowGroupId(address _id) constant returns (bytes32) {
        return logic_v1.getAllowGroupId(bytes32(_id));
    }

    /* show data object of history */
    function getObjectId(address _id) constant returns (bytes32) {
        return logic_v1.getObjectId(bytes32(_id));
    }

    /* record */

    function addRecord(address _id, bytes32 _recordId) {
        logic_v1.addRecord(msg.sender, bytes32(_id), _recordId);
    }

    function getLatestRecordId(address _id) constant returns (bytes32) {
        return logic_v1.getLatestRecordId(bytes32(_id));
    }

    // return all recordIds
    function getRecordIds(address _id) constant returns (bytes32[]) {
        bytes32 idBytes32 = bytes32(_id);
        bytes32[] memory recordIds = new bytes32[](logic_v1.getNumRecords(idBytes32));
        for(uint i = 0; i < recordIds.length; i++) {
            recordIds[i] = logic_v1.getRecordId(idBytes32, i);
        }
        return recordIds;
    }

    function getRecordObjectIds(address _id) constant returns (bytes32[]) {
        bytes32 idBytes32 = bytes32(_id);
        bytes32[] memory recordObjIds = new bytes32[](logic_v1.getNumRecords(idBytes32));
        for(uint i = 0; i < recordObjIds.length; i++) {
            recordObjIds[i] = logic_v1.getRecordObjId(idBytes32, i);
        }
        return recordObjIds;
    }

    /* ----------- privete functions ----------------- */

    function checkTimestamp(uint _timestamp) private constant returns (bool) {
        return (now - TIMESTAMP_RANGE < _timestamp && _timestamp < now + TIMESTAMP_RANGE);
    }
}
