# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

variable HPCR_CERT {
  type        = string
  description = "Public HPCR certificate for contract encryption"
  nullable    = true
  default     = null
}

variable IMAGEGREP11 {
  type        = string
  description = "grep11 image name."
}

variable IMAGENGINX {
  type        = string
  description = "nginx image name."
}

variable REGISTRY_URL {
  type        = string
  description = "Registry URL to pull an image."
}

variable REGISTRY_USERNAME {
  type        = string
  description = "Username to access your registry."
}

variable REGISTRY_PASSWORD {
  type        = string
  description = "Password to access your registry"
}

variable REGISTRY_CA {
  type        = string
  description = "Registry certificate authority in base64 (optional for private registries)"
  default     = ""
}

variable SYSLOG_HOSTNAME {
  type        = string
  description = "Syslog server hostname"
}

variable SYSLOG_PORT {
  type        = number
  description = "Syslog server port number"
}

variable SYSLOG_SERVER_CERT {
  type        = string
  description = "Syslog server certificate"
}

variable SYSLOG_CLIENT_CERT {
  type        = string
  description = "Syslog server client certificate"
}

variable SYSLOG_CLIENT_KEY {
  type        = string
  sensitive   = true
  description = "Syslog server client key"
}
