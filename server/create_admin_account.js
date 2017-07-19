const ethClient = require('eth-client');

function createPassword(len) {
    var c = 'abcdefghijklmnopqrstuvwxyz0123456789';
    let id = '';
    for (let i = 0; i < len; i++) {
        id += c[Math.floor(Math.random() * c.length)];
    }
    return id;
};

const password = createPassword(8);

ethClient.Account.create('https://beta.blockchain.z.com', password, function(err, instance) {
    if (err) {
        console.error(err);
    } else {
        console.log('address: ' + instance.getAddress());
        console.log('password: ' + password);
        console.log('key: ' + JSON.stringify(instance.serialize()));
    }
});
