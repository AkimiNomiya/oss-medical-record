const config = require('./config'),
    express = require('express'),
    app = express(),
    bodyParser = require('body-parser'),
    debug = require('debug')('server'),
    Promise = require('bluebird'),
    ethClient = require('eth-client');

app.listen(3000);

app.use('/medical-record', express.static(__dirname + '/public'));

app.use(bodyParser.urlencoded({ extended: true }));

app.post('/medical-record/api/hospital', function(req, res, next) {
    debug('body', req.body);
    const timestamp = req.body.timestamp;
    const name = req.body.name;
    const sign = req.body.sign;

    const hash = ethClient.utils.hashBySolidityType(['uint256', 'bytes32'], [timestamp, name]);
    debug('hash', hash);
    const address = ethClient.utils.recoverAddress(hash, sign);
    debug('address', address);

    const id = '0x' + require('crypto').randomBytes(32).toString('hex');
    debug('id', id);
    debug('account', config.admin.account);
    const admin = ethClient.Account.deserialize(config.admin.account);
    const contract = new ethClient.AltExecCnsContract(admin, config.cnsAddress);
    contract.sendTransaction(config.admin.password, 'Organization', 'create', [timestamp, id, address, name], config.organizationAbi, function(err, result) {
        if (err) return next(err);
        debug('result', result);
        res.status(200).send({ result: 'success', hospital: { id: id } });
        next();
    });
});

app.delete('/medical-record/api/hospital', function(req, res, next) {
    debug('body', req.body);
    const timestamp = req.body.timestamp;
    const id = req.body.id;

    const admin = ethClient.Account.deserialize(config.admin.account);
    const contract = new ethClient.AltExecCnsContract(admin, config.cnsAddress);
    contract.sendTransaction(config.admin.password, 'Organization', 'remove', [timestamp, id], config.organizationAbi, function(err, result) {
        if (err) return next(err);
        debug('result', result);
        res.status(200).send({ result: 'success' });
        next();
    });
});


app.use(function(req, res, next) {
    if (res.headersSent) return next();
    debug('err', 'NOT FOUND');
    res.status(404).send({ result: 'not found' });
    next();
});

app.use(function(err, req, res, next) {
    debug('err', err);
    if (!res.headersSent) res.status(500).send({ result: 'failure' });
});
