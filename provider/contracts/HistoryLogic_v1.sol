pragma solidity ^0.4.8;

import '../../gmo/contracts/VersionLogic.sol';
import '../../gmo/contracts/DataObject_v1.sol';
import '../../gmo/contracts/AddressGroup_v1.sol';
import './History_v1.sol';
import './HistoryField_v1.sol';
import './HistoryEvent_v1.sol';
import './Organization_v1.sol';
import './Record_v1.sol';

contract HistoryLogic_v1 is VersionLogic, History {
    HistoryField_v1 field_v1;
    HistoryEvent_v1 event_v1;
    bytes32 adminGroupId;
    ContractNameService gmoCns;

    /* ----------- for migration ----------------- */

    function HistoryLogic_v1(ContractNameService _cns, HistoryField_v1 _field, HistoryEvent_v1 _event, bytes32 _adminGroupId, ContractNameService _gmoCns) VersionLogic(_cns, CONTRACT_NAME) {
        field_v1 = _field;
        event_v1 = _event;
        adminGroupId = _adminGroupId;
        gmoCns = _gmoCns;
    }

    function setHistoryField_v1(HistoryField_v1 _field) onlyByProvider { field_v1 = _field; }
    function setHistoryEvent_v1(HistoryEvent_v1 _event) onlyByProvider { event_v1 = _event; }

    /* ----------- modifiers ----------------- */

    modifier onlyFromAdmin(address _from) {
        AddressGroup_v1 addressGroup = AddressGroup_v1(gmoCns.getLatestContract('AddressGroup'));
        if (!addressGroup.isMember(_from, adminGroupId)) throw;
        _;
    }

    modifier onlyFromAllowCnsContractLogic(address _sender, bytes32 _id) {
        VersionLogic logic = VersionLogic(_sender);
        if (!(isAllowCnsContract(logic.getCns(), logic.getContractName(), _id) || logic.getCns().isVersionLogic(_sender, logic.getContractName()))) throw;
        _;
    }

    /* ----------- functions called by version contract ----------------- */

    function create(address _id, bytes32 _objectId, bytes32 _dataHash) onlyByVersionContractOrLogic {
        // create data object
        DataObject_v1 dataObject_v1 = DataObject_v1(gmoCns.getLatestContract('DataObject'));
        dataObject_v1.create(_objectId, _id, _dataHash, cns, 'History');

        bytes32 readerId = dataObject_v1.getReaderId(_objectId);
        bytes32 writerId = dataObject_v1.getWriterId(_objectId);

        AddressGroup_v1 addressGroup = AddressGroup_v1(gmoCns.getLatestContract('AddressGroup'));
        address[] memory addrs = new address[](1);
        addrs[0] = _id;

        // create allow address group
        bytes32 allowGroupId = transferUniqueId(bytes32(_id));
        addressGroup.create(allowGroupId, this, new address[](0), cns, CONTRACT_NAME);
        addressGroup.addMembers(allowGroupId, addrs);

        addressGroup.addChild(readerId, allowGroupId);
        addressGroup.addChild(writerId, allowGroupId);

        field_v1.create(bytes32(_id), allowGroupId, _objectId);
        event_v1.create(bytes32(_id), allowGroupId, _objectId);
        field_v1.setAllowCnsContract(bytes32(_id), cns, 'Record', true);
    }

    function remove(bytes32 _id) onlyByVersionContractOrLogic {
        if (!isActive(_id)) throw;
        bytes32 allowGroupId = field_v1.getAllowGroupId(_id);
        AddressGroup_v1 addressGroup = AddressGroup_v1(gmoCns.getLatestContract('AddressGroup'));
        addressGroup.remove(allowGroupId);

        field_v1.remove(_id);
        event_v1.remove(_id);
    }

    function getObjectId(bytes32 _id) constant returns (bytes32) {
        if (!isActive(_id)) return 0;
        return field_v1.getObjectId(_id);
    }

    /* access controll */

    function addAllowGroup(bytes32 _id, bytes32 _organizationId) onlyByVersionContractOrLogic {
        if (!isActive(_id)) throw;
        AddressGroup_v1 addressGroup = AddressGroup_v1(gmoCns.getLatestContract('AddressGroup'));
        bytes32 parentId = field_v1.getAllowGroupId(_id);

        Organization_v1 organization = Organization_v1(cns.getLatestContract('Organization'));
        bytes32 childId =  organization.getMemberGroupId(_organizationId);

        addressGroup.addChild(parentId, childId);
        event_v1.addAllowGroup(_id, _organizationId);
    }

    function removeAllowGroup(bytes32 _id, bytes32 _organizationId) onlyByVersionContractOrLogic {
        if (!isActive(_id)) throw;
        AddressGroup_v1 addressGroup = AddressGroup_v1(gmoCns.getLatestContract('AddressGroup'));
        bytes32 parentId = field_v1.getAllowGroupId(_id);

        Organization_v1 organization = Organization_v1(cns.getLatestContract('Organization'));
        bytes32 childId =  organization.getMemberGroupId(_organizationId);

        addressGroup.removeChild(parentId, childId);
        event_v1.removeAllowGroup(_id, _organizationId);
    }

    function isAllowGroup(bytes32 _organizationId, bytes32 _id) constant returns (bool) {
        if (!isActive(_id)) return false;
        AddressGroup_v1 addressGroup = AddressGroup_v1(gmoCns.getLatestContract('AddressGroup'));
        bytes32 allowGroupId = field_v1.getAllowGroupId(_id);

        Organization_v1 organization = Organization_v1(cns.getLatestContract('Organization'));
        bytes32 organizationGroupId =  organization.getMemberGroupId(_organizationId);

        uint length = addressGroup.getChildrenLength(allowGroupId);
        for (uint i = 0; i < length; i++) {
            if (addressGroup.getChild(allowGroupId, i) == organizationGroupId) return true;
        }
        return false;
    }

    function isAllowGroupMember(address _account, bytes32 _id) constant returns (bool) {
        if (!isActive(_id)) return false;
        AddressGroup_v1 addressGroup = AddressGroup_v1(gmoCns.getLatestContract('AddressGroup'));
        bytes32 groupId = field_v1.getAllowGroupId(_id);
        return addressGroup.isMember(_account, groupId);
    }

    function getAllowGroupId(bytes32 _id) constant returns (bytes32) {
        if (!isActive(_id)) return 0;
        return field_v1.getAllowGroupId(_id);
    }

    /* prescription */

    function addRecord(address _sender, bytes32 _id, bytes32 _prescriptionId) onlyByVersionContractOrLogic onlyFromAllowCnsContractLogic(_sender, _id) {
        if (!isActive(_id)) throw;
        field_v1.addRecord(_id, _prescriptionId);
        event_v1.addRecord(_sender, _id, _prescriptionId);
    }

    function getLatestRecordId(bytes32 _id) constant returns (bytes32) {
        if (!isActive(_id)) return 0;
        return field_v1.getLatestRecordId(_id);
    }

    function getNumRecords(bytes32 _id) constant returns (uint) {
        if (!isActive(_id)) return 0;
        return field_v1.getNumRecords(_id);
    }

    function getRecordId(bytes32 _id, uint _index) constant returns (bytes32) {
        if (!isActive(_id)) return 0;
        return field_v1.getRecordId(_id, _index);
    }

    function getRecordObjId(bytes32 _id, uint _index) constant returns (bytes32) {
        if (!isActive(_id)) return 0;
        Record_v1 prescription = Record_v1(cns.getLatestContract('Record'));
        return prescription.getObjectId(field_v1.getRecordId(_id, _index));
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

}
