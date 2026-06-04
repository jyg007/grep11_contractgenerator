host-attestation: 
  HKD-$MACHINE1:
    description:  $MACHINE1_DESCRIPTION
    host-key-doc: $MACHINE1_HKD_B24
  HKD-$MACHINE2:
    description:  $MACHINE2_DESCRIPTION
    host-key-doc: $MACHINE2_HKD_B24
crypto-pt: 
  lock: false
  index-1:
    type: secret
    domain-id: "$HSMDOMAIN1.1"
    secret: $SECRET1_B24
    mkvp: $MKVP1
  index-2:
    type: secret
    domain-id: "$HSMDOMAIN2.1"
    secret: $SECRET1_B24
    mkvp: $MKVP1
  index-3:
    type: secret
    domain-id: "$HSMDOMAIN1.2"
    secret: $SECRET2_B24
    mkvp: $MKVP2
  index-4:
    type: secret
    domain-id: "$HSMDOMAIN2.2"
    secret: $SECRET2_B24
    mkvp: $MKVP2
  index-5:
    type: secret3
    domain-id: "$HSMDOMAIN1.3"
    secret: $SECRET3_B24
    mkvp: $MKVP3
  index-6:
    type: secret
    domain-id: "$HSMDOMAIN2.3"
    secret: $SECRET3_B24
    mkvp: $MKVP3
auths:
  "$REGISTRY_URL":
    password: "$REGISTRY_PASSWORD"
    username: "$REGISTRY_USERNAME"
cacerts:
- certificate: "$REGISTRY_CA"
logging:
  syslog:
    hostname: "$SYSLOG_HOSTNAME"
    port: $SYSLOG_PORT
    server: | 
$SYSLOG_SERVER_CERT
    cert: | 
$SYSLOG_CLIENT_CERT
    key: |
$SYSLOG_CLIENT_KEY
type: env
