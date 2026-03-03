1- Generate grep11server server/client and store it in srv.  Edit server.cnf if needed.
2- Edit adapter param in srv/grep11server1.yaml and srv/grep11server2.yaml
3- Run ./create_contract_shell.sh
4- Define vm domain (grep11/domain.xml) and install the contract.  Edit HSM uuid if necessaary.  If two HSM, specify the two uuids.


## Building `terraforms.tfvars`

### Q1:  Which registry are you using ?

1. Ask for registry credential to connect
2. Ask for root CA certificate used for the registry server certificate (TLS authent)
3. Specify the following parameters as done in `terraforms.tfvars.sample`
```
REGISTRY_URL
REGISTRY_USERNAME
REGISTRY_PASSWORD
REGISTRY_CA  (in base64 !, use base64 -w0 yourcertfile.crt command )
```

4. Upload nginx and grep11 containers onto this registry
5. Retrieve their signature using `skopeo inspect --format='{{index .Digest }}' docker://<registry IP>/grep11:latest  --creds registryuser:registrypass`
6. Specify the following parameters as done in `terraforms.tfvars.sample`
```
IMAGEGREP11
IMAGENGINX
```

### Q2:  Which rsyslog daemon will you forward logs ?
1. Ask for rsyslog TLS server certificate
2. Ask to create client key and client certificate using the same certificate authority
3. Specify the following parameters as done in `terraforms.tfvars.sample`
```
SYSLOG_HOSTNAME
SYSLOG_PORT
SYSLOG_SERVER_CERT
SYSLOG_CLIENT_CERT
SYSLOG_CLIENT_KEY
```
### Q3: Where is your IBM HPVS Software used ?  
1. Retrieve the software 
2. Retrieve the encryption file of your IBM HPVS runtime version
`cat config/certs/ibm-hyper-protect-container-runtime-X.X.X-encrypt.crt`
3. Specify the value as done in `terraforms.tfvars.sample` for `HPCR_CERT` parameter
4. Copy the `images/ibm-hyper-protect-container-runtime-X.X.X.qcow2` as `/var/lib/libvirt/images/hpcr` in your LPAR

### Q4: What about your HSM ?
1. Which domains are you using ? 
2. Set value for `HSMDOMAIN1` and `HSMDOMAIN2`
3. Have your retrive your Host Key file ?
4. Set value for `MACHINE1_HKD_B24` and `MACHINE2_HKD_B24` as well as serial number `MACHINE1` and `MACHINE2`.  
you can use the `getHKD.sh` to help:

```
$ getHKD.sh
Login at https://www.ibm.com/support/resourcelink/ and then download:
https://www.ibm.com/support/resourcelink/api/content/raw/hkd-public/HKD-3931-028A3B8.crt
```
