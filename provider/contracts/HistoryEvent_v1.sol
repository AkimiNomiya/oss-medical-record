pragma solidity ^0.4.8;

import './History.sol';
import '../../gmo/contracts/VersionEvent.sol';

contract HistoryEvent_v1 is VersionEvent, History {
    function HistoryEvent_v1(ContractNameService _cns) VersionEvent(_cns, CONTRACT_NAME) {}

    event Create(bytes32 indexed _id, bytes32 _allowGroupId, bytes32 _objectId);
    event Remove(bytes32 indexed _id);
    /* type : 1=add 2=remove */
    event ModifyAllowGroup(bytes32 indexed _id, bytes32 _groupId, uint _type);
    event AddPrescription(address _senderContractAddr, bytes32 _id, bytes32 indexed _recordId);

    function create(bytes32 _id, bytes32 _allowGroupId, bytes32 _objectId) {
         Create(_id, _allowGroupId, _objectId);
    }

    function remove(bytes32 _id) {
        Remove(_id);
    }

    function addAllowGroup(bytes32 _id, bytes32 _groupId) {
        ModifyAllowGroup(_id, _groupId, 1);
    }

    function removeAllowGroup(bytes32 _id, bytes32 _groupId) {
        ModifyAllowGroup(_id, _groupId, 2);
    }

    function addRecord(address _senderContractAddr, bytes32 _id, bytes32 _recordId) {
        AddPrescription(_senderContractAddr, _id, _recordId);
    }

}
