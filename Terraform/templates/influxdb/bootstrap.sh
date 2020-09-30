#!/bin/bash
influx -password '${INFLUXDB_PASSWORD}' -username '${INFLUXDB_USERNAME}' -execute '${INFLUXDB_COMMANDS}'
