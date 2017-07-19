var LOCAL_STORAGE = {};

var _doctorAccountKey = 'medical-record.doctor';
var _hospitalAccountKey = 'medical-record.hospital';
var _patientAccountKey = 'medical-record.patient';
var _hospitalIdKey = 'medical-record.hospital-id';

LOCAL_STORAGE.getHospitalAccount = function () {
    var serializedAccount = localStorage.getItem(_hospitalAccountKey);
    return serializedAccount ? ethClient.Account.deserialize(serializedAccount) : null;
};
LOCAL_STORAGE.setHospitalAccount = function (_account) {
    localStorage.setItem(_hospitalAccountKey, _account.serialize());
};
LOCAL_STORAGE.removeHospitalAccount = function () {
    localStorage.removeItem(_hospitalAccountKey);
};
LOCAL_STORAGE.getDoctorAccount = function () {
    var serializedAccount = localStorage.getItem(_doctorAccountKey);
    return serializedAccount ? ethClient.Account.deserialize(serializedAccount) : null;
};
LOCAL_STORAGE.setDoctorAccount = function (_account) {
    localStorage.setItem(_doctorAccountKey, _account.serialize());
};
LOCAL_STORAGE.getPatientAccount = function () {
    var serializedAccount = localStorage.getItem(_patientAccountKey);
    return serializedAccount ? ethClient.Account.deserialize(serializedAccount) : null;
};
LOCAL_STORAGE.setPatientAccount = function (_account) {
    localStorage.setItem(_patientAccountKey, _account.serialize());
};
LOCAL_STORAGE.getHospitalId = function () {
    var _hospitalId = localStorage.getItem(_hospitalIdKey);
    return _hospitalId ? _hospitalId : null;
};
LOCAL_STORAGE.setHospitalId = function (_hospitalId) {
    localStorage.setItem(_hospitalIdKey, _hospitalId);
};
LOCAL_STORAGE.removeHospitalId = function () {
    localStorage.removeItem(_hospitalIdKey);
};