# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

resource "local_file" "docker_compose" {
  content = templatefile(
    "${path.module}/grep11-c16.yml.tftpl",
    { tpl = {
      imagegrep11 = var.IMAGEGREP11,
      imagenginx = var.IMAGENGINX,
    } },
  )
  filename = "docker-compose/docker-compose.yml"
  file_permission = "0664"
}

# archive of the folder containing docker-compose file. This folder could create additional resources such as files
# to be mounted into containers, environment files etc. This is why all of these files get bundled in a tgz file (base64 encoded)
resource "hpcr_tgz" "workload" {
  depends_on = [ local_file.docker_compose ]
  folder = "docker-compose"
}


locals {
  compose = {
    "compose" : {
      "archive" : hpcr_tgz.workload.rendered
    }
  }
  workload = merge(local.workload_template, local.compose)
  contract = yamlencode({
    "env" : local.env,
    "workload" : local.workload
  })
}

# In this step we encrypt the fields of the contract and sign the env and workload field. The certificate to execute the
# encryption it built into the provider and matches the latest HPCR image. If required it can be overridden.
# We use a temporary, random keypair to execute the signature. This could also be overriden.
resource "hpcr_contract_encrypted" "contract" {
  contract  = local.contract
  cert      = var.HPCR_CERT == "" ? null : var.HPCR_CERT
}

resource "local_file" "contract" {
  count    = 1
  content  = yamlencode(local.contract)
  filename = "grep11-c16_plain.yml"
  file_permission = "0664"
}

resource "local_file" "contract_encrypted" {
  content  = hpcr_contract_encrypted.contract.rendered
  filename = "grep11-c16.yml"
  file_permission = "0664"
}
