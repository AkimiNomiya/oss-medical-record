[Medical Record](https://oss.blockchain.z.com/docs/oss/medical-record/) - GMO Blockchain Open Source
==================================================

License
--------------------------------------
License is [here](./LICENSE.txt).

Apart from forbidding the use of this software for criminal activity, this license is similar to the [MIT License](https://opensource.org/licenses/mit-license.php).

GMO Blockchain Open Source Common License document is [here](https://guide.blockchain.z.com/docs/oss/license/).

DEMO
--------------------------------------
You can check the operation of this sample project on this page.

http://oss.blockchain.z.com/medical-record/

Usage Guides
--------------------------------------

## Create Z.com Cloud Blockchain environment
see [Setup Development Environment](https://guide.blockchain.z.com/docs/init/setup/)

## Install application
```bash
git clone --recursive https://github.com/zcom-cloud-blockchain/oss-medical-record.git
npm install
```

## Create admin account
```bash
node server/create_admin_account.js
```

## Configure for contracts
Create provider/config.json based on provider/config_template.json. Edit "adminAddress" and "adminGroupId". "adminGroupId" is a random string.

## Deploy contracts
```bash
truffle migrate
```

## Set up for Z.com Cloud Blockchain
see [Basic Configuration](https://guide.blockchain.conoha.jp/docs/dapp/setup/)

## Configure for server
Create server/config.json based on server/config_template.json. Edit "account" and "password" of admin which you created.

## Configure for client
Create server/public/js/config.json based on server/public/js/config_template.json. Edit "CNS_ADDRESS" which you deployed.


## Start application
```bash
node server/app.js
```