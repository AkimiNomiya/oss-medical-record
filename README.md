[Medical Record Sharing](https://guide.blockchain.z.com/docs/oss/medical-record/) - GMO Blockchain Open Source
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

Explanation
--------------------------------------
- #### GMO Blockchain Open Source
    http://guide.blockchain.z.com/docs/oss/

- #### Medical Record Sharing
    http://guide.blockchain.z.com/docs/oss/medical-record/

Usage Guides
--------------------------------------

#### Create Z.com Cloud Blockchain environment
see [Setup Development Environment](https://guide.blockchain.z.com/docs/init/setup/)

#### Install application
```bash
git clone --recursive https://github.com/zcom-cloud-blockchain/oss-medical-record.git
cd oss-medical-record/server
npm install
```

#### Create admin account
```bash
cd oss-medical-record
node server/create_admin_account.js
```

#### Configure for contracts
Create provider/config.json based on provider/config_template.json. Edit "adminAddress" and "adminGroupId". "adminGroupId" is a random string.

#### Deploy contracts
```bash
cd oss-medical-record/provider
truffle migrate
```

#### Set up for Z.com Cloud Blockchain
See [Basic Configuration](https://guide.blockchain.z.com/docs/dapp/setup/)

- ##### Set CNS address on admin console
  1. Open a file 'provider\build\contracts\ContractNameService.json'
  
  2. Use 'networks.12345.address' as CNS address to register as ABI address on admin console

See [Contract Creation Process](https://guide.blockchain.z.com/docs/dapp/contract/)
- ##### Set Contract ABIs on admin console
  1. Open following files
    ```bash
    'provider\build\contracts\History_v1.json'
    'provider\build\contracts\Organization_v1.json'
    'provider\build\contracts\Record_v1.json'
    ```
  2. Use 'networks.12345.address' and 'abi' values to register as Contract ABIs on admin console

#### Configure for server
Create server/config.json based on server/config_template.json. Edit "account" and "password" of admin which you created.

#### Configure for client
Create server/public/js/config.json based on server/public/js/config_template.json. Edit "CNS_ADDRESS" which you deployed.

#### Start application
```bash
cd oss-medical-record
node server/app.js
```
