resource "proxmox_vm_qemu" "grafana" {
  vmid       = var.GRAFANA_VMID
  name       = var.GRAFANA_HOSTNAME
  clone      = var.GRAFANA_TEMPLATE_NAME
  full_clone = var.GRAFANA_FULL_CLONE

  target_node = var.PROXMOX_HOSTNAME
  pool        = var.GRAFANA_RESOURCE_POOL


  sockets = var.GRAFANA_SOCKETS
  cores   = var.GRAFANA_CORES
  memory  = var.GRAFANA_MEMORY

  network {
    id     = 0
    model  = var.GRAFANA_NET_TYPE
    bridge = var.GRAFANA_NET_BRIDGE
    tag    = var.GRAFANA_VLAN_ID
  }

  disk {
    id           = 0
    storage      = var.GRAFANA_STORAGE
    storage_type = var.GRAFANA_STORAGE_TYPE
    type         = var.GRAFANA_DISK_TYPE
    size         = var.GRAFANA_DISK_SIZE
    backup       = var.GRAFANA_ENABLE_BACKUPS
    iothread     = true
  }

  onboot = var.GRAFANA_ENABLE_ONBOOT
  agent  = 1

  os_type      = "cloud-init"
  ipconfig0    = "ip=${var.GRAFANA_IP_ADDRESS}/${var.GRAFANA_SUBNET_SIZE},gw=${var.GRAFANA_GATEWAY}"
  nameserver   = var.GRAFANA_NAMESERVER
  searchdomain = var.GRAFANA_SEARCH_DOMAIN

  connection {
    type        = "ssh"
    user        = var.GRAFANA_TEMPLATE_USERNAME
    host        = var.GRAFANA_IP_ADDRESS
    private_key = file(var.GRAFANA_SSH_PRIVATE_KEY_PATH)
  }

  # Generate a file hierarchy for configuration templates
  provisioner "remote-exec" {
    inline = [
      "mkdir /etc/tks",
      "mkdir /etc/tks/grafana",
      "mkdir /etc/tks/influxdb",
      "mkdir /etc/tks/telegraf",
      "mkdir /etc/tks/prometheus",
      "mkdir /etc/tks/docker",
    ]
  }

  # Grafana Configuration
  provisioner "file" {
    destination = "/etc/tks/grafana/grafana.ini"
    content = templatefile("${path.root}/templates/grafana/grafana.ini", {
      GRAFANA_USERNAME      = var.GRAFANA_USERNAME
      GRAFANA_PASSWORD      = var.GRAFANA_PASSWORD
      GRAFANA_SMTP_SERVER   = var.GRAFANA_SMTP_SERVER
      GRAFANA_SMTP_PORT     = var.GRAFANA_SMTP_PORT
      GRAFANA_SMTP_USERNAME = var.GRAFANA_SMTP_USERNAME
      GRAFANA_SMTP_PASSWORD = var.GRAFANA_SMTP_PASSWORD
      GRAFANA_HOSTNAME      = var.GRAFANA_HOSTNAME
      GRAFANA_SEARCH_DOMAIN = var.GRAFANA_SEARCH_DOMAIN
      POSTGRES_USERNAME     = var.POSTGRES_USERNAME
      POSTGRES_PASSWORD     = var.POSTGRES_PASSWORD
      POSTGRES_DATABASE     = var.POSTGRES_DATABASE
    })
  }

  # Grafana Datasources
  provisioner "file" {
    destination = "/etc/tks/grafana/datasources.yml"
    content = templatefile("${path.root}/templates/grafana/datasources.yml", {
      INFLUXDB_DATABASE = var.INFLUXDB_DATABASE
      INFLUXDB_USERNAME = var.INFLUXDB_USERNAME
      INFLUXDB_PASSWORD = var.INFLUXDB_PASSWORD
    })
  }

  # InfluxDB Configuration
  provisioner "file" {
    destination = "/etc/tks/influxdb/influxdb.conf"
    content = templatefile("${path.root}/templates/influxdb/influxdb.conf", {
      INFLUXDB_UDP_DATABASE = var.INFLUXDB_UDP_DATABASE
    })
  }

  # InfluxDB Extra Commands
  provisioner "file" {
    destination = "/etc/tks/influxdb/bootstrap.sh"
    content = templatefile("${path.root}/templates/influxdb/bootstrap.sh", {
      INFLUXDB_USERNAME = var.INFLUXDB_USERNAME
      INFLUXDB_PASSWORD = var.INFLUXDB_PASSWORD
      INFLUXDB_COMMANDS = var.INFLUXDB_COMMANDS
    })
  }

  # Telegraf Configuration
  provisioner "file" {
    destination = "/etc/tks/telegraf/telegraf.conf"
    content = templatefile("${path.root}/templates/telegraf/telegraf.conf", {
      GRAFANA_HOSTNAME  = var.GRAFANA_HOSTNAME
      INFLUXDB_USERNAME = var.INFLUXDB_USERNAME
      INFLUXDB_PASSWORD = var.INFLUXDB_PASSWORD
    })
  }

  # Prometheus Configuration
  provisioner "file" {
    destination = "/etc/tks/prometheus/prometheus.yml"
    content = templatefile("${path.root}/templates/prometheus/prometheus.yml", {
    })
  }

  # Docker Compose Configuration
  provisioner "file" {
    destination = "/etc/tks/docker/docker-compose.yml"
    content = templatefile("${path.root}/templates/docker/docker-compose.yml", {
      GRAFANA_VERSION    = var.GRAFANA_VERSION
      GRAFANA_PLUGINS    = var.GRAFANA_PLUGINS
      POSTGRES_VERSION   = var.POSTGRES_VERSION
      POSTGRES_USERNAME  = var.POSTGRES_USERNAME
      POSTGRES_PASSWORD  = var.POSTGRES_PASSWORD
      POSTGRES_DATABASE  = var.POSTGRES_DATABASE
      INFLUXDB_VERSION   = var.INFLUXDB_VERSION
      INFLUXDB_DATABASE  = var.INFLUXDB_DATABASE
      INFLUXDB_USERNAME  = var.INFLUXDB_USERNAME
      INFLUXDB_PASSWORD  = var.INFLUXDB_PASSWORD
      PROMETHEUS_VERSION = var.PROMETHEUS_VERSION
    })
  }

  # Grafana Dashboards
  provisioner "file" {
    source      = "${path.root}/dashboards"
    destination = "/etc/tks/grafana/"
  }

  # Bootstrapping script
  provisioner "file" {
    destination = "/etc/tks/bootstrap.sh"
    content = templatefile("${path.root}/templates/bootstrap.sh", {
      GRAFANA_HOSTNAME      = var.GRAFANA_HOSTNAME
      GRAFANA_SEARCH_DOMAIN = var.GRAFANA_SEARCH_DOMAIN
      GRAFANA_VERSION       = var.GRAFANA_VERSION
      GRAFANA_USERNAME      = var.GRAFANA_USERNAME
      POSTGRES_VERSION      = var.POSTGRES_VERSION
      POSTGRES_USERNAME     = var.POSTGRES_USERNAME
      POSTGRES_PASSWORD     = var.POSTGRES_PASSWORD
      POSTGRES_DATABASE     = var.POSTGRES_DATABASE
      NFS_HOSTNAME          = var.NFS_HOSTNAME
      NFS_MOUNTPOINT        = var.NFS_MOUNTPOINT
      NFS_ARGUMENTS         = var.NFS_ARGUMENTS
    })
  }
  provisioner "remote-exec" { inline = ["bash /etc/tks/bootstrap.sh"] }
}
