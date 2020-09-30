##################################################
# Terraform - Proxmox Provider Configuration     #
##################################################
variable "PROXMOX_HOSTNAME" {
  type        = string
  description = "The hostname, fully qualified domain name, or IP Address used to network with the Proxmox cluster."
}
variable "PROXMOX_PORT" {
  type        = number
  default     = 8006
  description = "The port used to network with the Proxmox API endpoint. "
}
variable "PROXMOX_USER" {
  type        = string
  default     = "root@pam"
  description = "The user used to connect to the Proxmox API. May be required to include `@pam`."
}
variable "PROXMOX_PASSWORD" {
  type        = string
  description = "The password for the user used to connect to the Proxmox API."
}
variable "PROXMOX_ALLOW_INSECURE" {
  type        = bool
  default     = true
  description = "Whether or not it should be allowed for Terraform to connect to Proxmox without a trusted SSL certificate authority."
}
variable "PROXMOX_NUM_PROCESSES" {
  type        = number
  default     = 4
  description = "The number of simultaneous Proxmox actions that can occur. (EG: Creating multiple resources)"
}
variable "PROXMOX_API_TIMEOUT" {
  type        = number
  default     = 300
  description = "The timeout value (expressed in seconds) for Proxmox API calls."
}


##################################################
# Virtual Machine - General Configuration        #
##################################################
variable "GRAFANA_TEMPLATE_NAME" {
  type        = string
  default     = "TKS-Debian-Template"
  description = "The name of the Proxmox template from which you want to clone the required virtual machines."
}
variable "GRAFANA_TEMPLATE_USERNAME" {
  type        = string
  default     = "tks"
  description = "The username with which you can connect to the template."
}
variable "GRAFANA_RESOURCE_POOL" {
  type        = string
  default     = "TKS"
  description = "The Proxmox Resource Pool into which TKS will be deployed. (Must exist already)"
}
variable "GRAFANA_ENABLE_BACKUPS" {
  type        = bool
  default     = false
  description = "Whether or not the TKS virtual machines should automatically be backed up by proxmox."
}
variable "GRAFANA_ENABLE_ONBOOT" {
  type        = bool
  default     = false
  description = "Whether or not the TKS virtual machines should automatically be started on boot by proxmox."
}


##################################################
# Virtual Machine - Compute Configuration        #
##################################################
variable "GRAFANA_VMID" {
  type        = number
  default     = null
  description = "The VM ID to associate with the virtual machine."
}
variable "GRAFANA_FULL_CLONE" {
  type        = bool
  default     = true
  description = "Whether or not the virtual machine should be a full clone."
}
variable "GRAFANA_SOCKETS" {
  type        = number
  default     = 1
  description = "The number of CPU sockets to add to the virtual machine."
}
variable "GRAFANA_CORES" {
  type        = number
  default     = 2
  description = "The number of CPU cores to add to the virtual machine."
}
variable "GRAFANA_MEMORY" {
  type        = number
  default     = 2048
  description = "The amount of memory, expressed in megabytes, to add to the virtual machine."
}


##################################################
# Virtual Machine - Network Configuration        #
##################################################
variable "GRAFANA_NET_TYPE" {
  type        = string
  default     = "virtio"
  description = "The type of virtual network card used for the virtual machine."
}
variable "GRAFANA_NET_BRIDGE" {
  type        = string
  default     = "vmbr0"
  description = "The name of the network bridge used for the virtual machine."
}
variable "GRAFANA_VLAN_ID" {
  type        = number
  default     = null
  description = "If configured, the VLAN ID that is associated with the network card for the virtual machine."
}
variable "GRAFANA_IP_ADDRESS" {
  type        = string
  description = "The IP Address to associate with the virtual machine."
}
variable "GRAFANA_SUBNET_SIZE" {
  type        = number
  default     = 24
  description = "The subnet size expressed in bits for the virtual machine."
}
variable "GRAFANA_GATEWAY" {
  type        = string
  description = "The network gateway that should be configured for the virtual machine."
}
variable "GRAFANA_NAMESERVER" {
  type        = string
  default     = "8.8.8.8"
  description = "The DNS server that should be configured for the virtual machine."
}
variable "GRAFANA_HOSTNAME" {
  type        = string
  default     = "tks-grafana"
  description = "The name and network hostname to associate with the virtual machine. (Search Domain is configured separately)"
}
variable "GRAFANA_SEARCH_DOMAIN" {
  type        = string
  default     = null
  description = "The DNS search domain that should be configured for the virtual machine."
}
variable "GRAFANA_SSH_PRIVATE_KEY_PATH" {
  type        = string
  description = "The path of the local filesystem for an SSH Private Key that will be used to authenticate against the virtual machine."
}


##################################################
# Virtual Machine - Storage Configuration        #
##################################################
variable "GRAFANA_STORAGE" {
  type        = string
  description = "The name of the storage in Proxmox onto which the TKS virtual machines should be deployed."
}
variable "GRAFANA_STORAGE_TYPE" {
  type        = string
  description = "The type of the storage onto which Terraform will be deploying the virtual machine."
}
variable "GRAFANA_DISK_TYPE" {
  type        = string
  default     = "scsi"
  description = "The type of virtual hard disk that will be attached to the virtual machine."
}
variable "GRAFANA_DISK_SIZE" {
  type        = number
  default     = 30
  description = "The size, expressed in gigabytes, of the virtual hard disk that will be attached to the virtual machine."
}


##################################################
# Grafana Configuration                          #
##################################################
variable "GRAFANA_VERSION" {
  type        = string
  default     = "7.2.0"
  description = "The Grafana Docker container tag to use."
}
variable "GRAFANA_USERNAME" {
  type        = string
  default     = "tks"
  description = "The default username for Grafana admin account."
}
variable "GRAFANA_PASSWORD" {
  type        = string
  description = "The default password for the Grafana admin account."
}
variable "GRAFANA_SMTP_SERVER" {
  type        = string
  default     = "smtp.gmail.com"
  description = "The SMTP server for Grafana to use."
}
variable "GRAFANA_SMTP_PORT" {
  type        = number
  default     = 587
  description = "The SMTP port for Grafana to use."
}
variable "GRAFANA_SMTP_USERNAME" {
  type        = string
  description = "The SMTP username for Grafana to use."
}
variable "GRAFANA_SMTP_PASSWORD" {
  type        = string
  description = "The SMTP password for Grafana to use."
}


##################################################
# Postgres Configuration                         #
##################################################
variable "POSTGRES_VERSION" {
  type        = string
  default     = "11"
  description = "The Postgres Docker container tag to use."
}
variable "POSTGRES_USERNAME" {
  type        = string
  default     = "tks"
  description = "The Postgers user for Grafana to use."
}
variable "POSTGRES_PASSWORD" {
  type        = string
  description = "The Postgres password for Grafana to use."
}
variable "POSTGRES_DATABASE" {
  type        = string
  default     = "grafana"
  description = "The Postgres database for Grafana to use."
}


##################################################
# InfluxDB Configuration                         #
##################################################
variable "INFLUXDB_VERSION" {
  type        = string
  default     = "1.8"
  description = "The InfluxDB Docker container tag to use."
}
variable "INFLUXDB_USERNAME" {
  type        = string
  default     = "tks"
  description = "The default InfluxDB user for InfluxDB to use."
}
variable "INFLUXDB_PASSWORD" {
  type        = string
  description = "The default InfluxDB password for InfluxDB to use."
}
variable "INFLUXDB_DATABASE" {
  type        = string
  default     = "influxdb"
  description = "The default InfluxDB database for InfluxDB to use."
}
variable "INFLUXDB_UDP_DATABASE" {
  type        = string
  default     = "udp"
  description = "The InfluxDB database to use for storing UDP metrics."
}
variable "INFLUXDB_COMMANDS" {
  type        = string
  default     = ""
  description = "The list of commands to run on InfluxDB after starting it."
}


##################################################
# Prometheus Configuration                       #
##################################################
variable "PROMETHEUS_VERSION" {
  type        = string
  default     = "latest"
  description = "The Prometheus Docker container tag to use."
}
