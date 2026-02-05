#!/bin/bash

#
# Licensed Materials - Property of IBM
#
# (c) Copyright IBM Corp. 2023
#
# The source code for this program is not published or otherwise
# divested of its trade secrets, irrespective of what has been
# deposited with the U.S. Copyright Office
#

touch vendor-data
echo "local-hostname: grep11" > meta-data
#cloud-localds cloud-init -V vendor-data user-data meta-data

genisoimage -output /var/lib/libvirt/images/grep11-cloudinit -volid cidata -joliet -rock vendor-data user-data meta-data network-config

#cp cloud-init /var/lib/libvirt/images/grep11-2-cloudinit
qemu-img create -f qcow2 /var/lib/libvirt/images/grep11-overlay.qcow2 10G
