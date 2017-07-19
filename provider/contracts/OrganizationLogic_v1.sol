pragma solidity ^0.4.8;

import '../../gmo/contracts/VersionLogic.sol';
import '../../gmo/contracts/AddressGroup_v1.sol';
import './Organization_v1.sol';
import './OrganizationField_v1.sol';
import './OrganizationEvent_v1.sol';

contract OrganizationLogic_v1 is VersionLogic, Organization {
    OrganizationField_v1 field_v1;
    OrganizationEvent_v1 event_v1;
    bytes32 adminGroupId;
    ContractNameService gmoCns;

    /* ----------- for migration ----------------- */

    function OrganizationLogic_v1(ContractNameService _cns, OrganizationField_v1 _field, OrganizationEvent_v1 _event, bytes32 _adminGroupId, ContractNameService _gmoCns) VersionLogic(_cns, CONTRACT_NAME) {
        field_v1 = _field;
        event_v1 = _event;
        adminGroupId = _adminGroupId;
        gmoCns = _gmoCns;
    }

    function setOrganizationField_v1(OrganizationField_v1 _field) onlyByProvider { field_v1 = _field; }
    function setOrganizationEvent_v1(OrganizationEvent_v1 _event) onlyByProvider { event_v1 = _event; }

    /* ----------- modifiers ----------------- */

    modifier onlyFromAdmin(address _from) {
        AddressGroup_v1 addressGroup = AddressGroup_v1(gmoCns.getLatestContract('AddressGroup'));
        if (!addressGroup.isMember(_from, adminGroupId)) throw;
        _;
    }

    modifier onlyFromController(address _from, bytes32 _id) {
        if (!isController(_id, _from)) throw; _;
    }

    modifier onlyFromAllowCnsContractLogic(address _sender, bytes32 _id) {
        VersionLogic logic = VersionLogic(_sender);
        if (!(isAllowCnsContract(logic.getCns(), logic.getContractName(), _id) || logic.getCns().isVersionLogic(_sender, logic.getContractName()))) throw;
        _;
    }

    /* ----------- functions called by version contract ----------------- */

    function create(address _from, bytes32 _id, address _initAddr, bytes32 _name) onlyByVersionContractOrLogic onlyFromAdmin(_from) {
        // create group ids
        bytes32 controllerGroupId = transferUniqueId(_id);
        bytes32 memberGroupId = transferUniqueId(sha3(_id));

        createAddressGroup(controllerGroupId, _initAddr);
        createAddressGroup(memberGroupId, _initAddr);

        field_v1.create(_id, _name, controllerGroupId, memberGroupId);
        event_v1.create(_from, _id, controllerGroupId, memberGroupId, _initAddr);
        field_v1.setAllowCnsContract(_id, cns, 'History', true);
    }

    function remove(address _from, bytes32 _id) onlyByVersionContractOrLogic onlyFromAdmin(_from) {
        if (!isActive(_id)) throw;
        bytes32 controllerGroupId = field_v1.getControllerGroupId(_id);
        bytes32 memberGroupId = field_v1.getMemberGroupId(_id);

        AddressGroup_v1 addressGroup = getAddressGroupContract();
        addressGroup.remove(controllerGroupId);
        addressGroup.remove(memberGroupId);

        field_v1.remove(_id);
        event_v1.remove(_from, _id);
    }

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

    function addController(address _from, bytes32 _id, address _addr) onlyByVersionContractOrLogic onlyFromController(_from, _id) {
        if(!isActive(_id)) throw;
        bytes32 controllerGroupId = field_v1.getControllerGroupId(_id);
        addOne(controllerGroupId, _addr);
        event_v1.addController(_from, _id, _addr);
    }

    function addMember(address _from, bytes32 _id, address _addr) onlyByVersionContractOrLogic onlyFromController(_from, _id) {
        if(!isActive(_id)) throw;
        bytes32 memberGroupId = field_v1.getMemberGroupId(_id);
        addOne(memberGroupId, _addr);
        event_v1.addMember(_from, _id, _addr);
    }

    function removeController(address _from, bytes32 _id, address _addr) onlyByVersionContractOrLogic onlyFromController(_from, _id) {
        if(!isActive(_id)) throw;
        bytes32 controllerGroupId = field_v1.getControllerGroupId(_id);
        removeOne(controllerGroupId, _addr);
        event_v1.removeController(_from, _id, _addr);
    }

    function removeMember(address _from, bytes32 _id, address _addr) onlyByVersionContractOrLogic onlyFromController(_from, _id) {
        if(!isActive(_id)) throw;
        bytes32 memberGroupId = field_v1.getMemberGroupId(_id);
        removeOne(memberGroupId, _addr);
        event_v1.removeMember(_from, _id, _addr);
    }

    function isController(bytes32 _id, address _addr) constant returns (bool) {
        if(!isActive(_id)) return false;
        bytes32 controllersId = field_v1.getControllerGroupId(_id);
        AddressGroup_v1 group = getAddressGroupContract();
        return group.isMember(_addr, controllersId);
    }

    function isMember(bytes32 _id, address _addr) constant returns (bool) {
        if(!isActive(_id)) return false;
        bytes32 controllersId = field_v1.getMemberGroupId(_id);
        AddressGroup_v1 group = getAddressGroupContract();
        return group.isMember(_addr, controllersId);
    }

    function getName(bytes32 _id) constant returns (bytes32) {
        if(!isActive(_id)) return 0;
        return field_v1.getName(_id);
    }

    function getMemberGroupId(bytes32 _id) constant returns (bytes32) {
        if(!isActive(_id)) return 0;
        return field_v1.getMemberGroupId(_id);
    }

    /* ----------- privete functions ----------------- */

    function isActive(bytes32 _id) private constant returns (bool) {
        return (field_v1.getIsCreated(_id) && !field_v1.getIsRemoved(_id));
    }

    function getAddressGroupContract() private constant returns (AddressGroup_v1) {
        return AddressGroup_v1(gmoCns.getLatestContract('AddressGroup'));
    }

    function createAddressGroup(bytes32 _id, address _account) private {
        address[] memory accounts = new address[](1);
        accounts[0] = _account;
        AddressGroup_v1 group = getAddressGroupContract();
        group.create(_id, this, accounts, cns, CONTRACT_NAME);
    }

    function addOne(bytes32 _groupId, address _memberAddr) private {
        AddressGroup_v1 group = getAddressGroupContract();
        address[] memory addrs = new address[](1);
        addrs[0] = _memberAddr;
        group.addMembers(_groupId, addrs);
    }

    function removeOne(bytes32 _groupId, address _memberAddr) private {
        AddressGroup_v1 group = getAddressGroupContract();
        address[] memory addrs = new address[](1);
        addrs[0] = _memberAddr;
        group.removeMembers(_groupId, addrs);
    }

}