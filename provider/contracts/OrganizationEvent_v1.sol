pragma solidity ^0.4.8;

import './Organization.sol';
import '../../gmo/contracts/VersionEvent.sol';

contract OrganizationEvent_v1 is VersionEvent, Organization {
    function OrganizationEvent_v1(ContractNameService _cns) VersionEvent(_cns, CONTRACT_NAME) {}

    event Create(address _creator, bytes32 indexed _id, bytes32 _controllersId, bytes32 _membersId, address _initAddr);
    event Remove(address _remover, bytes32 indexed _id);
    /* type : 1=add 2=remove */
    event ModifyController(address indexed _modifier, bytes32 indexed _id, address _addr, uint _type);
    event ModifyMember(address indexed _modifier, bytes32 indexed _id, address _addr, uint _type);

    function create(address _creator, bytes32 _id, bytes32 _controllersId, bytes32 _membersId, address _initAddr) onlyByVersionLogic {
        Create(_creator, _id, _controllersId, _membersId, _initAddr);
    }

    function remove(address _remover, bytes32 _id) {
        Remove(_remover, _id);
    }

    function addController(address _modifier, bytes32 _id, address _addr) onlyByVersionLogic {
        ModifyController(_modifier, _id, _addr, 1);
    }

    function removeController(address _modifier, bytes32 _id, address _addr) onlyByVersionLogic {
        ModifyController(_modifier, _id, _addr, 2);
    }

    function addMember(address _modifier, bytes32 _id, address _addr) onlyByVersionLogic {
        ModifyMember(_modifier, _id, _addr, 1);
    }

    function removeMember(address _modifier, bytes32 _id, address _addr) onlyByVersionLogic {
        ModifyMember(_modifier, _id, _addr, 2);
    }
}
