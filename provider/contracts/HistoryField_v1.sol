pragma solidity ^0.4.8;

import '../../gmo/contracts/VersionField.sol';
import './History.sol';

contract HistoryField_v1 is VersionField, History {
    struct Field {
        bool isCreated;
        bool isRemoved;
        mapping (address => mapping(bytes32 => bool)) allowCnsContracts; //address=>(contractname=>isAllowGroup);
        bytes32[] recordIds;
        bytes32 allowGroupId;
        bytes32 objectId;
    }

    mapping(bytes32 => Field) public fields; // convert personal address to bytes32

    function HistoryField_v1(ContractNameService _cns) VersionField(_cns, CONTRACT_NAME) {}

    /* OVERRIDE */
    function existIdAtCurrentVersion(bytes32 _id) constant returns (bool) {
        return fields[_id].isCreated;
    }

    /* OVERRIDE */
    function setDefault(bytes32 _id) private {
        fields[_id] = Field({isCreated:true, isRemoved:false, recordIds: new bytes32[](0), allowGroupId:0, objectId:0});
    }

    function allowCnsContracts(bytes32 _id, address _cns, bytes32 _contractName) constant returns (bool) {
        return fields[_id].allowCnsContracts[_cns][_contractName];
    }

    function setAllowCnsContract(bytes32 _id, address _cns, bytes32 _contractName, bool _isAdded) onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].allowCnsContracts[_cns][_contractName] = _isAdded;
    }

    function isAllowCnsContract(address _cns, bytes32 _contractName, bytes32 _id) constant returns (bool) {
        if (shouldReturnDefault(_id)) return false;
        return fields[_id].allowCnsContracts[_cns][_contractName];
    }

    /* ----------- create / remove History ----------------- */

    function create(bytes32 _id, bytes32 _allowGroupId, bytes32 _objectId) onlyByNextVersionOrVersionLogic {
        if(exist(_id)) throw;
        fields[_id] = Field({isCreated:true, isRemoved:false, recordIds: new bytes32[](0), allowGroupId:_allowGroupId, objectId:_objectId});
    }

    function remove(bytes32 _id) onlyByNextVersionOrVersionLogic {
        if(!exist(_id)) throw;
        fields[_id].isRemoved = true;
    }

    /* ----------- getters and setters----------------- */

    function getIsCreated(bytes32 _id) constant returns (bool) {
        if(shouldReturnDefault(_id)) return true;
        return fields[_id].isCreated;
    }

    function getIsRemoved(bytes32 _id) constant returns (bool) {
        if(shouldReturnDefault(_id)) return false;
        return fields[_id].isRemoved;
    }

    function getAllowGroupId(bytes32 _id) constant returns (bytes32) {
        if(shouldReturnDefault(_id)) return 0;
        return fields[_id].allowGroupId;
    }

    function getObjectId(bytes32 _id) constant returns (bytes32) {
        if(shouldReturnDefault(_id)) return 0;
        return fields[_id].objectId;
    }

    function getLatestRecordId(bytes32 _id) constant returns (bytes32) {
        if(shouldReturnDefault(_id)) return 0;

        uint len = fields[_id].recordIds.length;
        return fields[_id].recordIds[len-1];
    }

    function getNumRecords(bytes32 _id) constant returns (uint) {
        if(shouldReturnDefault(_id)) return 0;
        return fields[_id].recordIds.length;
    }

    function getRecordId(bytes32 _id, uint _index) constant returns (bytes32) {
        if(shouldReturnDefault(_id)) return 0;
        return fields[_id].recordIds[_index];
    }

    function setIsCreated(bytes32 _id, bool _isCreated) onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].isCreated = _isCreated;
    }

    function setIsRemoved(bytes32 _id, bool _isRemoved) onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].isRemoved = _isRemoved;
    }

    function setAllowGroupId(bytes32 _id, bytes32 _groupId) onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].allowGroupId = _groupId;
    }

    function setObjectId(bytes32 _id, bytes32 _objectId) onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].objectId = _objectId;
    }

    function addRecord(bytes32 _id, bytes32 _recordId) onlyByNextVersionOrVersionLogic {
        prepare(_id);
        for(uint i=0; i<fields[_id].recordIds.length; i++) {
            if(fields[_id].recordIds[i] == _recordId) return;
        }
        fields[_id].recordIds.push(_recordId);
    }

}
