#!/bin/bash
influx -password '${INFLUXDB_PASSWORD}' -username '${INFLUXDB_USER}' -execute '${INFLUXDB_COMMANDS}'
