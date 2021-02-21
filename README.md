# TKS - Deploy Grafana

This repository can be used on its own but it is intended to be used as a submodule of [TKS](https://github.com/zimmertr/TKS). TKS enables enthusiasts and administrators alike to easily provision highly available and production-ready Kubernetes clusters and other modern infrastructure on Proxmox VE.

* [Summary](#Summary)
* [Requirements](#Requirements)
* [Instructions](#Instructions)
<hr>

## Summary

`Deploy Grafana`  provisions a monitoring stack to Proxmox in a single virtual machine. Including:

  * Grafana for visualization
  * InfluxDB for storing metrics
  * Prometheus for stroing metrics
  * Telegraf for sending metrics from the monitoring server
  * Example dashboards to get started monitoring Proxmox and the stack itself.

By default, the server will only monitor itself. However, optional steps can be performed to send metrics to pre-defined data sources and Grafana dashboards.

<hr>

## Requirements

This project assumes you have a working [Proxmox server](https://github.com/zimmertr/TKS-Bootstrap_Proxmox) and leverages Telmate's [Terraform provider](https://github.com/Telmate/terraform-provider-proxmox). It uses a VM template produced by [TKS-Build_Template](https://github.com/zimmertr/TKS-Build_Template).

This monitoring stack is pre-configured to listen for metrics from both Proxmox and a Federated Prometheus server running inside of a Kubernetes cluster. To enable these features, be sure to follow the **Optional** steps below.
<hr>

## Instructions

### Prepare Local Environment

1. Download and install Telmate's [Terraform provider](https://github.com/Telmate/terraform-provider-proxmox) for Proxmox.

   ```bash
   cd /tmp
   git clone https://github.com/Telmate/terraform-provider-proxmox.git
   cd terraform-provider-proxmox

   go install github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provider-proxmox
   go install github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provisioner-proxmox
   make

   mkdir ~/.terraform.d/plugins
   cp bin/terraform-provider-proxmox ~/.terraform.d/plugins
   cp bin/terraform-provisioner-proxmox ~/.terraform.d/plugins
   rm -rf /tmp/terraform-provider-proxmox
   ```

2. Set your environment variables. Supported values can be found in `./Terraform/variables.tf`.

   ```bash
   # Proxmox
   export TF_VAR_PROXMOX_HOSTNAME="earth"
   export TF_VAR_PROXMOX_PASSWORD="P@ssw0rd1\!" # Be sure to escape special characters

   # Compute
   export TF_VAR_GRAFANA_SOCKETS=1
   export TF_VAR_GRAFANA_CORES=2
   export TF_VAR_GRAFANA_MEMORY=4098

   # Storage
   export TF_VAR_GRAFANA_STORAGE="FlashPool"
   export TF_VAR_GRAFANA_STORAGE_TYPE="zfspool"
   export TF_VAR_GRAFANA_DISK_SIZE=50

   # General
   export TF_VAR_GRAFANA_VMID=4020
   export TF_VAR_GRAFANA_HOSTNAME="tks-mon"
   export TF_VAR_GRAFANA_FULL_CLONE=true
   export TF_VAR_GRAFANA_ENABLE_BACKUPS=true
   export TF_VAR_GRAFANA_ENABLE_ONBOOT=true

   # Networking
   export TF_VAR_GRAFANA_VLAN_ID=40
   export TF_VAR_GRAFANA_IP_ADDRESS="192.168.40.20"
   export TF_VAR_GRAFANA_SUBNET_SIZE=24
   export TF_VAR_GRAFANA_GATEWAY="192.168.40.1"
   export TF_VAR_GRAFANA_NAMESERVER="192.168.1.100"
   export TF_VAR_GRAFANA_SEARCH_DOMAIN="sol.milkyway"
   export TF_VAR_GRAFANA_SSH_PRIVATE_KEY_PATH="/Users/tj/.ssh/Sol.Milkyway/tks-mon.sol.milkyway"

   # Grafana
   export TF_VAR_GRAFANA_VERSION="7.2.0"
   export TF_VAR_GRAFANA_PASSWORD="P@ssword1\!" # Be sure to escape special characters
   export TF_VAR_GRAFANA_SMTP_USERNAME="thomaszimmerman93@gmail.com"
   export TF_VAR_GRAFANA_SMTP_PASSWORD="P@ssw0rd1\!" # Be sure to escape special characters

   # Postgres
   export TF_VAR_POSTGRES_PASSWORD="P@ssw0rd1\!" # Be sure to escape special characters

   # InfluxDB
   export TF_VAR_INFLUXDB_PASSWORD="P@ssw0rd1\!" # Be sure to escape special characters
   export TF_VAR_INFLUXDB_UDP_DATABASE="proxmox"
   export TF_VAR_INFLUXDB_COMMANDS="CREATE DATABASE unifi; CREATE DATABASE ups"
   
   # NFS Client
   
   export TF_VAR_NFS_HOSTNAME="earth.sol.milkyway"
   export TF_VAR_NFS_MOUNTPOINT="/mnt/DataPool/Monitoring"
   ```


3. Drop your Dashboard `json` files into `./Terraform/dashboards/DIRECTORY/` and configure `./Terraform/dashboards/grafana_dashboards.yml` accordingly. These dashboards will automatically be imported on first startup. Some dashboards are included by default for monitoring the monitoring server itself as well as your Proxmox hosts.

4. Configure `./Terraform/templates/grafana/datasources.yml` according to the data sources you have in your environment. By default, this stack will include the following:

   * Influxdb-`${INFLUXDB_DATABASE}`: Created for you from a passed in variable.
   * Influxdb-telegraf: Created automatically for storing the local agent's metrics
   * Influxdb-proxmox: Created automatically for storing Proxmox metrics.
   * Prometheus: Created automatically for stroing metrics.

5. **OPTIONAL STEP:** Configure Proxmox to send metrics to your InfluxDB Database by following the instructions [here](https://pve.proxmox.com/wiki/External_Metric_Server). It is unclear if Proxmox requires a reboot after modifying this file, but it is likely that some services must be restarted.

   My configurion looks like:

   ```bash
   influxdb: tks-mon
   server tks-mon.sol.milkyway
   port 8089
   ```

6. **OPTIONAL STEP:** Deploy a [Federated Prometheus](https://github.com/zimmertr/TKS-Deploy_Kubernetes_Apps/tree/master/Federated_Monitoring) monitoring stack to your Kubernetes cluster to obtain cluster metrics. Then update the `federate` job in `Terraform/templates/prometheus/prometheus.yml` to reflect your hostname. Remove or add any scrape configs according to your environment. Be sure to also adjust the Kustomize overlays for the federation deployment according to your worker node hostnames & TLS configuration.


7. Deploy the VM.

   ```bash
   terraform init
   terraform validate
   terraform apply
   ```
