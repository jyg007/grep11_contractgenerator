## mTLS certs used for grep11 connection

The HPVS grep11 vm will use the server certs.  This step is optional as the current key and cert can be kept for the testing in an initial setup.  CA, client and server keys and certificates used for grep11 authentication are stored in the `certs` directory. 

1. You can keep existing files but in `certs` directory the `gen.sh` script can be used to recreate CA, client, server certs for grep11. Edit server.cnf if needed.
2. Do not leave private keys in this directory when your setup has been completed
3. Edit your client `/etc/hosts` if you wanted to test the connection locally and add:
```
192.168.96.21 grep11.svc.net             # [OSO config for tenant 0 using hipersocket]
or 192.168.122.100 grep11.svc.net        # [KVM default network]
```
4. `https://github.com/jyg007/ep11go` includes numerous sample to test the connection
   
## Building `terraforms.tfvars`

### Q1:  Which registry are you using ?

1. Ask for registry credential to connect
2. Ask for root CA certificate used for the registry server certificate (TLS authent)
3. Specify the following parameters as done in `terraforms.tfvars.sample`
```
REGISTRY_URL     (use IP address if possible)
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
SYSLOG_HOSTNAME   (use IP address if possible)
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
3. Have your retrieved your Host Key file ?
4. Set value for `MACHINE1_HKD_B24` and `MACHINE2_HKD_B24` as well as serial number `MACHINE1` and `MACHINE2`.  
you can use the `getHKD.sh` to help:

```
$ getHKD.sh
Login at https://www.ibm.com/support/resourcelink/ and then download:
https://www.ibm.com/support/resourcelink/api/content/raw/hkd-public/HKD-3931-028A3B8.crt
```
5. Retrieve your HSM domain master key verification pattern.  You can use `ep11info -D` for this.  And set the value for `MKVP` paramater.
```
# ep11info -D
 module-nr domain-nr imprinted      sign. thr.     revoke thr.      compliance                                                                wrapping key
==========================================================================================================================================================
         3        19       YES               1               1        00000001    50D94C73 FBF3137D 2239F132 191026A5 CD166583 EE557ECA CBB701E3 00000000
         4        19       YES               1               1        00000001    50D94C73 FBF3137D 2239F132 191026A5 CD166583 EE557ECA CBB701E3 00000000
```
6. Generate a random ep11 passtrhough key for your grep11 and set value for `SECRET_B24`  [ *SENSITIVE* PARAMETER, make sure the value is not publicly known ]
```
openssl rand -base64 32
```
Your contract can now be generated using `create_contract_shell.sh` script.  It will be in grep11 directory.

## GREP11 HPVS VM

In the `grep11` directory you will find all you need to create your grep11 HPVS VM.

1. Modify the adapter number and domain number in the `activate_passthrough.sh` script:
```
CARD1=0x03
CARD2=0x02
DOMAIN1=0x11
```

2. Activate the passthough mode on your LPAR by executing the `activate_passthrough.sh` script.  The `lszcrypt -V` should indicate you domain is managed by the vfio_ap driver:

```
$ activate_passthrough.sh
$ lszcrypt -V
CARD.DOM TYPE  MODE        STATUS     REQUESTS  PENDING HWTYPE QDEPTH FUNCTIONS  DRIVER     
--------------------------------------------------------------------------------------------
03       CEX8P EP11-Coproc online            0        0     14     08 -----XN-F- cex4card   
03.0011  CEX8P EP11-Coproc in use            -        -     14     08 -----XN-F- vfio_ap
```
3. Select the hpvs domain definition that fits your network:

`domain.xml` is to be used with OSO and hipersocket
`domain1.xml` is to be used for a standalone grep11 service listening via a NAT adapter on the KVM default network.

4. Create your HPVS VM (KVM guest):
```
virsh define domain1.xml
```

5. Install your HPVS contract (`user-data` file)

If using `domain1.xml`
    1. Edit the `create-cloudinit.sh` script and the following command 

from
`genisoimage -output /var/lib/libvirt/images/grep11-cloudinit -volid cidata -joliet -rock vendor-data user-data meta-data network-config`

to
`genisoimage -output /var/lib/libvirt/images/grep11-cloudinit -volid cidata -joliet -rock vendor-data user-data meta-data`

    2. Fix the IP address of your grep11 by editing the default definition by fixing the mac address (as defined in `domain1.xml`) and an IP like `192.168.122.100` in this example which is part of `192.168.122.*/24` default kvm network.  For example:

```
$ virsh net-edit default

  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'>
        <lease expiry='0'/>
      </range>
      <host mac='52:54:00:1e:81:09' name='grep11' ip='192.168.122.100'/>
    </dhcp>
  </ip>
```

6. start up your HPVS VM

```
$ virsh start grep11 --console
Domain 'grep11-3' started
Connected to domain 'grep11'
Escape character is ^] (Ctrl + ])
LOADPARM=[        ]
Using virtio-blk.
Using SCSI scheme.
..........................................................................................................................
# HPL11 build:25.11.0 enabler:25.10.0
# Tue Mar  3 13:53:10 UTC 2026
# Machine Type/Plant/Serial: 3931/02/8A3B8
# delete old root partition...
# create new root partition...
# encrypt root partition...
# create root filesystem...
# write OS to root disk...
# decrypt user-data...
2 token decrypted, 0 encrypted token ignored
# user-data contains HKD info
# user-data contains HKD for this machine.
# HKD description: techzone
# performing ultravisor attestation
# CUID=0x65a5c53f0ec3ba1e0bcddaebf903caea
# crypto drivers loaded
# configuring AP device(s)
# configuring AP #1
Successfully added the secret
# secret store not locked
# create attestation data
# set hostname...
# finish root disk setup...
# Tue Mar  3 13:53:34 UTC 2026
# HPL11 build:25.11.0 enabler:25.10.0
# HPL11099I: bootloader end
hpse-network-config-validator[1121]: HPL13000I: Validation Successfull -> Validation of Schema is Successful
hpcr-network[1143]: Interface(s) defined in network config -> [enc8]
hpcr-network[1143]: HPL13004I: Netplan file is updated -> configured IP parameters - [enc8]
hpcr-networkcheck[1200]: HPL14001I: Network connectivity check in progress.
hpcr-networkcheck[1200]: Reverse DNS lookup Failed for hostname: 192.168.**.** , Attempting local connection.
hpcr-networkcheck[1200]: Performing connectivity check for given hostname
hpcr-networkcheck[1200]: Unable to reach the specified hostname; please verify the address
hpcr-networkcheck[1200]: Reverse DNS lookup Failed for hostname: 192.168.**.** , Attempting local connection.
hpcr-networkcheck[1200]: Performing connectivity check for given hostname
hpcr-networkcheck[1200]: Unable to reach the specified hostname; please verify the address
hpcr-networkcheck[1200]: Reverse DNS lookup Failed for hostname: 192.168.**.** , Attempting local connection.
hpcr-networkcheck[1200]: Performing connectivity check for given hostname
hpcr-networkcheck[1200]: HPL14000I: Network connectivity check completed successfully.
hpcr-logging[1261]: Configuring logging ...
hpcr-logging[1266]: Version [1.1.213]
hpcr-logging[1266]: Configuring logging, input [/var/hyperprotect/user-data.decrypted] ...
hpcr-logging[1266]: HPL01010I: Logging has been setup successfully.
hpcr-logging[1261]: Logging has been configured
```



