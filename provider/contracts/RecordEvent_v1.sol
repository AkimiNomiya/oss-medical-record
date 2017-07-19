pragma solidity ^0.4.8;

import './Record.sol';
import '../../gmo/contracts/VersionEvent.sol';

contract RecordEvent_v1 is VersionEvent, Record {
    function RecordEvent_v1(ContractNameService _cns) VersionEvent(_cns, CONTRACT_NAME) {}

    event Create(address indexed _creator, bytes32 indexed _id, address indexed _historyId, bytes32 _objectId);
    event Remove(address indexed _remover, bytes32 indexed _id);
    event Update(address indexed _updater, bytes32 indexed _id, bytes32 _objectId);

    function create(address _creator, bytes32 _id, address _historyId, bytes32 _objectId) {
        Create (_creator, _id, _historyId, _objectId);
    }

    function remove(address _remover, bytes32 _id) {
        Remove(_remover, _id);
    }

    function update(address _updater, bytes32 _id, bytes32 _objectId){
        Update(_updater, _id, _objectId);
    }
}
