#!/bin/bash
set -e

main(){
  sudo mkdir /var/log/tks
  sudo chown tks:tks /var/log/tks

  echo "TKS - $(date) - Setting the hostname."
  configure_hostname

  echo "TKS - $(date) - Installing Docker Compose."
  install_compose > /var/log/tks/install_compose.log 2>&1

  echo "TKS - $(date) - Deploying Grafana."
  deploy_grafana > /var/log/tks/deploy_grafana.log 2>&1

  echo "TKS - $(date) - Waiting for Apt."
  wait_for_apt > /var/log/tks/wait_for_apt.log 2>&1

  echo "TKS - $(date) - Deploying Telegraf."
  deploy_telegraf > /var/log/tks/deploy_telegraf.log 2>&1

  echo "TKS - $(date) - Grafana deployment successful."
}

configure_hostname(){
  sudo hostnamectl set-hostname ${GRAFANA_HOSTNAME}.${GRAFANA_SEARCH_DOMAIN}
}

install_compose(){
  sudo curl -L \
    "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose

  sudo chmod +x /usr/local/bin/docker-compose
}

deploy_grafana(){
  sudo mkdir -p /opt/tks/grafana/{data,logs}
  sudo mkdir /opt/tks/{postgres,influxdb}
  sudo chown -R tks:tks /opt/tks

  cd /etc/tks/
  sudo docker-compose up -d
}

wait_for_apt(){
  timeout=$(($(date +%s) + 600))

  while pgrep apt > /dev/null; do

      time=$(date +%s)

      if [[ $time -ge $timeout ]];
      then
          echo "Apt hasn't exited in 10 minutes."
          exit 1
      fi

      echo "Apt still running."
      sleep 1
  done;

  echo "Apt is no longer detected."
}

deploy_telegraf(){
  sudo apt-get update
  sudo apt-get install -y apt-transport-https

  sudo wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
  source /etc/os-release
  sudo test $VERSION_ID = "10" && echo "deb https://repos.influxdata.com/debian buster stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

  sudo apt-get update
  sudo apt-get install -y telegraf

  sudo mv /etc/tks/telegraf.conf /etc/telegraf/telegraf.conf
  sudo chown -R telegraf:telegraf /etc/telegraf/
  sudo usermod -aG docker telegraf

  sudo systemctl enable --now telegraf
  sudo systemctl restart telegraf # Not sure why. but nothing works until this is ran.
}

main
