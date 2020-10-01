# TKS Deploy Grafana

## Summary

Deploy a monitoring stack to Proxmox in a single virtual machine. Including:

  * Grafana for visualization
  * InfluxDB for storing metrics
  * Prometheus for stroing metrics
  * Telegraf for sending metrics from the monitoring server
  * Example dashboards to get started monitoring Proxmox and the stack itself.

## Warning

This is a work of progress using the TKS template with the SSH hot swapped out during first boot. It won't work unless you know what you're doing.

## Instructions

1) Set your environment variables.

```bash
  # Proxmox
  export TF_VAR_PROXMOX_HOSTNAME="earth"
  export TF_VAR_PROXMOX_PASSWORD="P@ssw0rd1\!" # Be sure to escape special characters

  # Compute
  export TF_VAR_GRAFANA_SOCKETS=1
  export TF_VAR_GRAFANA_CORES=2
  export TF_VAR_GRAFANA_MEMORY=409809

  # Storage
  export TF_VAR_GRAFANA_STORAGE="FlashPool"
  export TF_VAR_GRAFANA_STORAGE_TYPE="zfspool"
  export TF_VAR_GRAFANA_DISK_SIZE=50

  # General
  export TF_VAR_GRAFANA_VMID=4020
  export TF_VAR_GRAFANA_HOSTNAME="Mimas"
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
  export TF_VAR_GRAFANA_SSH_PRIVATE_KEY_PATH="/Users/tj/.ssh/Sol.Milkyway/mimas.sol.milkyway"

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
  export TF_VAR_INFLUXDB_COMMANDS="CREATE DATABASE unifi; CREATE DATABASE ups; CREATE DATABASE odroid;"
```


2) Drop your Dashboard `json` files into `./Terraform/dashboards/DIRECTORY/` and configure `./Terraform/dashboards/grafana_dashboards.yml` accordingly. These dashboards will automatically be imported on first startup. Some dashboards are included by default for monitoring the monitoring server itself as well as your Proxmox hosts.

3) Configure `./Terraform/templates/grafana/datasources.yml` according to the data sources you have in your environment. By default, this stack will include the following:

* Influxdb-${INFLUXDB_DATABASE}: Created for you from a passed in variable.
* Influxdb-telegraf: Created automatically for storing the local agent's metrics
* Influxdb-proxmox: Created automatically for storing Proxmox metrics.
* Prometheus: Created automatically for stroing metrics.

3) **OPTIONAL STEP** Configure Proxmox to send metrics to your InfluxDB Database by following the instructions [here](https://pve.proxmox.com/wiki/External_Metric_Server). It is unclear if Proxmox requires a reboot after modifying this file, but it is likely that some services must be restarted.

My configurion looks like:

```bash
influxdb: Mimas
  server mimas.sol.milkyway
  port 8089
```

4) Deploy the VM.

```bash
terraform init
terraform validate
terraform apply
```
