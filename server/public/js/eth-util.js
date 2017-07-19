var ETH_UTIL = {};
var BASE_URL = 'https://beta.blockchain.z.com';

/** Create client Key on this browse. and save to local storage (for demo). */
ETH_UTIL.generateNewAccount = function (callback) {
    ethClient.Account.create(BASE_URL, '', function (err, _account) {
        if (err) {
            console.log(err);
            alert('err on key creation! check console.');
            return;
        }
        callback(_account);
    });
};

ETH_UTIL.getContract = function (account) {
    return new ethClient.AltExecCnsContract(account, CNS);
}

ETH_UTIL.fromUtf8 = function (str) {
    str = utf8.encode(str);
    var hex = '';
    for (var i = 0; i < str.length; i++) {
        var code = str.charCodeAt(i);
        if (code === 0) break;
        var n = code.toString(16);
        hex += n.length < 2 ? '0' + n : n;
    }
    return '0x' + hex;
}

ETH_UTIL.toUtf8 = function (hex) {
    let str = '';
    for (let i = 2; i < hex.length; i += 2) {
        const code = parseInt(hex.substr(i, 2), 16);
        if (code === 0)
            break;
        str += String.fromCharCode(code);
    }
    return utf8.decode(str);
};