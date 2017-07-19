pragma solidity ^0.4.8;

import '../../gmo/contracts/VersionLogic.sol';
import '../../gmo/contracts/DataObject_v1.sol';
import '../../gmo/contracts/AddressGroup_v1.sol';
import './Record.sol';
import './Record_v1.sol';
import './RecordField_v1.sol';
import './RecordEvent_v1.sol';
import './History_v1.sol';

contract RecordLogic_v1 is VersionLogic, Record {
    RecordField_v1 field_v1;
    RecordEvent_v1 event_v1;
    bytes32 adminGroupId;
    ContractNameService gmoCns;

    /* ----------- for migration ----------------- */

    function RecordLogic_v1(ContractNameService _cns, RecordField_v1 _field, RecordEvent_v1 _event, bytes32 _adminGroupId, ContractNameService _gmoCns) VersionLogic(_cns, CONTRACT_NAME) {
        field_v1 = _field;
        event_v1 = _event;
        adminGroupId = _adminGroupId;
        gmoCns = _gmoCns;
    }

    function setRecordField_v1(RecordField_v1 _field) onlyByProvider { field_v1 = _field; }
    function setRecordEvent_v1(RecordEvent_v1 _event) onlyByProvider { event_v1 = _event; }

    /* ----------- modifiers ----------------- */

    modifier onlyFromAdmin(address _from) {
        AddressGroup_v1 addressGroup = AddressGroup_v1(gmoCns.getLatestContract('AddressGroup'));
        if (!addressGroup.isMember(_from, adminGroupId)) throw;
        _;
    }

    modifier onlyFromAllowGroupMember(address _from, address _historyId) {
        History_v1 history = History_v1(cns.getLatestContract('History'));
        if(!history.isAllowGroupMember(_from, _historyId)) throw;
        _;
    }

    modifier onlyFromAllowCnsContractLogic(address _sender, bytes32 _id) {
        VersionLogic logic = VersionLogic(_sender);
        if (!(isAllowCnsContract(logic.getCns(), logic.getContractName(), _id) || logic.getCns().isVersionLogic(_sender, logic.getContractName()))) throw;
        _;
    }

    /* ----------- functions called by version contract ----------------- */

    function create(address _from, bytes32 _id, address _historyId, bytes32 _objectId, bytes32 _dataHash) onlyByVersionContractOrLogic onlyFromAllowGroupMember(_from, _historyId){
        DataObject_v1 dataObject = DataObject_v1(gmoCns.getLatestContract('DataObject'));
        History_v1 history = History_v1(cns.getLatestContract('History'));

        // create data object
        dataObject.create(_objectId, _from, _dataHash, cns, 'Record');
        bytes32 historyAllowGroup = history.getAllowGroupId(_historyId);
        addAllowGroup(_objectId, historyAllowGroup);
        history.addRecord(_historyId, _id);

        field_v1.create(_from, _id, _historyId, _objectId);
        event_v1.create(_from, _id, _historyId, _objectId);
        field_v1.setAllowCnsContract(_id, cns, 'History', true);
    }

    function update(address _from, bytes32 _id, bytes32 _objectId, bytes32 _dataHash) onlyByVersionContractOrLogic onlyFromAllowGroupMember(_from, field_v1.getHistory(_id)) {
        if (!isActive(_id)) throw;
        if(_objectId != field_v1.getObjectId(_id)) throw;

        DataObject_v1 dataObject = DataObject_v1(gmoCns.getLatestContract('DataObject'));
        dataObject.setHashByWriter(_objectId, _from, _dataHash);
        event_v1.update(_from, _id, _objectId);
    }

    function remove(address _from, bytes32 _id) onlyByVersionContractOrLogic onlyFromAllowGroupMember(_from, field_v1.getHistory(_id)) {
        if (!isActive(_id)) throw;
        DataObject_v1 dataObject = DataObject_v1(gmoCns.getLatestContract('DataObject'));
        bytes32 objectId = field_v1.getObjectId(_id);
        dataObject.remove(objectId);

        field_v1.remove(_id);
        event_v1.remove(_from, _id);
    }

    function getObjectId(bytes32 _id) constant returns (bytes32) {
        if (!isActive(_id)) return 0;
        return field_v1.getObjectId(_id);
    }

    /* AllowCnsContract */

    function addAllowCnsContract(address _sender, bytes32 _id, address _cns, bytes32 _contractName) onlyByVersionContractOrLogic onlyFromAllowCnsContractLogic(_sender, _id) {
        if (!isActive(_id)) throw;
        field_v1.setAllowCnsContract(_id, _cns, _contractName, true);
    }

    function removeAllowCnsContract(address _sender, bytes32 _id, address _cns, bytes32 _contractName) onlyByVersionContractOrLogic onlyFromAllowCnsContractLogic(_sender, _id) {
        if (!isActive(_id)) throw;
        field_v1.setAllowCnsContract(_id, _cns, _contractName, false);
    }

    function isAllowCnsContract(address _cns, bytes32 _contractName, bytes32 _id) constant returns (bool) {
        if (!isActive(_id)) return false;
        return field_v1.isAllowCnsContract(_cns, _contractName, _id);
    }

    /* ----------- privete functions ----------------- */

    function isActive(bytes32 _id) private constant returns (bool) {
        return (field_v1.getIsCreated(_id) && !field_v1.getIsRemoved(_id));
    }

    function addAllowGroup(bytes32 _objectId, bytes32 _allowGroupId) private {
        DataObject_v1 dataObject = DataObject_v1(gmoCns.getLatestContract('DataObject'));
        AddressGroup_v1 addressGroup = AddressGroup_v1(gmoCns.getLatestContract('AddressGroup'));

        // add child allowGroup to reader and writer
        bytes32 readerId = dataObject.getReaderId(_objectId);
        bytes32 writerId = dataObject.getWriterId(_objectId);
        addressGroup.addChild(readerId, _allowGroupId);
        addressGroup.addChild(writerId, _allowGroupId);
    }
}
