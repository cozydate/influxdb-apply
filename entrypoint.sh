#!/bin/sh -ev
influxd &
/influxdb-apply /influxdb-apply.yaml https://localhost:8086/
wait
