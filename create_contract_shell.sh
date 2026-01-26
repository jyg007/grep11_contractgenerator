#!/bin/bash

# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

#terraform init
#terraform destroy -auto-approve

. ./terraform.tfvars



rm -rf ./docker-compose/*
cp -rf ./cfg ./docker-compose
cp -rf ./nginx ./docker-compose
#terraform apply -auto-approve

sed -e 's#${tpl.imagegrep11}#'$IMAGEGREP11"#" -e 's#${tpl.imagenginx}#'$IMAGENGINX"#" grep11-c16.yml.tftpl > ./docker-compose/docker-compose.yml

sed -e 's/<<-EOT/$(cat <<-EOT /' -e 's/^EOT/EOT\n)/' ./terraform.tfvars > ./o.$$ 
for i in IMAGE SYSLOG REGISTRY MACHINE2 MACHINE2_DESCRIPTION MACHINE2_HKD_B24 HSMDOMAIN2 MACHINE1 MACHINE1_DESCRIPTION MACHINE1_HKD_B24 HSMDOMAIN1 SECRET_B24 MKVP HELLO HPCR_CERT
do
  sed -i "s/^$i/export $i/" ./o.$$
done

. ./o.$$
rm ./o.$$

sed -e "s/HSMDOMAIN/$HSMDOMAIN1/" grep11server.tpl > srv/grep11server1.yaml
sed -e "s/HSMDOMAIN/$HSMDOMAIN2/" grep11server.tpl > srv/grep11server2.yaml
cp -rf ./srv ./docker-compose

export COMPOSE=`tar -cz -C docker-compose/ . | base64 -w0`
WORKLOAD=`pwd`/grep11.workload.yml
envsubst < workload.tpl > $WORKLOAD

ENV=`pwd`/grep11.env.yml
envsubst < env.tpl > $ENV
sed -i '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/ s/^/      /' $ENV
sed -i '/-----BEGIN PRIVATE KEY-----/,/-----END PRIVATE KEY-----/ s/^/      /' $ENV

CONTRACT_KEY=.ibm-hyper-protect-container-runtime-encrypt.crt

envsubst < hpcr_contractkey.tpl > $CONTRACT_KEY

PASSWORD=`openssl rand -base64 32`
#ENCRYPTED_PASSWORD="$(echo -n "$PASSWORD" | base64 -d | openssl rsautl -encrypt -inkey $CONTRACT_KEY -certin | base64 -w0 )"
ENCRYPTED_PASSWORD=$(printf "%s" "$PASSWORD" | openssl pkeyutl -encrypt -inkey "$CONTRACT_KEY" -certin -pkeyopt rsa_padding_mode:pkcs1 | base64 -w0)
ENCRYPTED_WORKLOAD="$(echo -n "$PASSWORD" | base64 -d | openssl enc -aes-256-cbc -pbkdf2 -pass stdin -in "$WORKLOAD" | base64 -w0)"
echo "workload: hyper-protect-basic.${ENCRYPTED_PASSWORD}.${ENCRYPTED_WORKLOAD}" > grep11.yml

PASSWORD=`openssl rand -base64 32`
#ENCRYPTED_PASSWORD="$(echo -n "$PASSWORD" | base64 -d | openssl rsautl -encrypt -inkey $CONTRACT_KEY -certin | base64 -w0 )"
ENCRYPTED_PASSWORD=$(printf "%s" "$PASSWORD" | openssl pkeyutl -encrypt -inkey "$CONTRACT_KEY" -certin -pkeyopt rsa_padding_mode:pkcs1 | base64 -w0)
ENCRYPTED_ENV="$(echo -n "$PASSWORD" | base64 -d | openssl enc -aes-256-cbc -pbkdf2 -pass stdin -in "$ENV" | base64 -w0)"
echo "env: hyper-protect-basic.${ENCRYPTED_PASSWORD}.${ENCRYPTED_ENV}" >> grep11.yml
 
rm $CONTRACT_KEY

cp grep11.yml grep11/user-data

