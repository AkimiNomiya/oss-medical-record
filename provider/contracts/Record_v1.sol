pragma solidity ^0.4.8;

import '../../gmo/contracts/VersionContract.sol';
import './Record.sol';
import './RecordLogic_v1.sol';

contract Record_v1 is VersionContract, Record {
    RecordLogic_v1 public logic_v1;
    uint constant TIMESTAMP_RANGE = 600;

    function Record_v1(ContractNameService _cns, RecordLogic_v1 _logic) VersionContract(_cns, CONTRACT_NAME) {logic_v1 = _logic;}

    function create(bytes _sign, bytes32 _objectId, bytes32 _dataHash, uint _timestamp, bytes32 _id, address _historyId) {
        if(!checkTimestamp(_timestamp)) throw;

        bytes32 hash = calcEnvHash('create');
        hash = sha3(hash, _objectId);
        hash = sha3(hash, _dataHash);
        hash = sha3(hash, _timestamp);
        hash = sha3(hash, _id);
        hash = sha3(hash, _historyId);
        address from = recoverAddress(hash, _sign);

        logic_v1.create(from, _id, _historyId, _objectId, _dataHash);
    }

    function remove(bytes _sign, uint _timestamp, bytes32 _id) {
        if(!checkTimestamp(_timestamp)) throw;

        bytes32 hash = calcEnvHash('remove');
        hash = sha3(hash, _timestamp);
        hash = sha3(hash, _id);
        address from = recoverAddress(hash, _sign);

        logic_v1.remove(from, _id);
    }

    function update(bytes _sign, bytes32 _objectId, bytes32 _dataHash, uint _timestamp, bytes32 _id) {
        if(!checkTimestamp(_timestamp)) throw;

        bytes32 hash = calcEnvHash('update');
        hash = sha3(hash, _objectId);
        hash = sha3(hash, _dataHash);
        hash = sha3(hash, _timestamp);
        hash = sha3(hash, _id);
        address from = recoverAddress(hash, _sign);

        logic_v1.update(from, _id, _objectId, _dataHash);
    }

    /* get object ID from Record ID */
    function getObjectId(bytes32 _id) constant returns (bytes32) {
        return logic_v1.getObjectId(_id);
    }

    /* get object IDs from Record IDs */
    function getObjectIds(bytes32[] _ids) constant returns (bytes32[]) {
        for(uint i = 0; i < objectIds.length; i++) {
        bytes32[] memory objectIds = new bytes32[](_ids.length);
            objectIds[i] = logic_v1.getObjectId(_ids[i]);
        }
        return objectIds;
    }

    /* ----------- privete functions ----------------- */

    function checkTimestamp(uint _timestamp) private constant returns (bool) {
        return (now - TIMESTAMP_RANGE < _timestamp && _timestamp < now + TIMESTAMP_RANGE);
    }
}
