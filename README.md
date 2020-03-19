# influxdb-apply

```
Usage: influxdb-apply YAML_FILE URL
```
You can use `influxdb-apply` in automated deployment scripts to configure InfluxDB.

`influxdb-apply` is a Python 2 program that reads an `influxdb-apply.yaml` file and updates InfluxDB
users and databases to match what's in the file.  It deletes all other users and databases.

## influxdb-apply.yaml

```yaml
# influxdb-apply.yaml
users:
 # First user must have a password and grant_all_privileges:true .
 - name: admin
   password: 'pass-admin'
   grant_all_privileges: true
 - name: telegraf
   password: 'pass-telegraf'  # For HTTP Basic authentication.
 - name: grafana
   password: 'pass-grafana'
 - name: user2  # Authenticates with a token.  Gets new random password on every apply.

databases:
 - name: _internal # Do not delete.
 - name: db1
   grant_read_to: [grafana]
   grant_write_to: [telegraf, user2]
   grant_all_to: []
```

## Examole

Build the Docker image from [`Dockerfile`](Dockerfile):
```
$ docker build --tag influxdb-with-apply .
```

Create a container.  Inside the container, [`entrypoint.sh`](entrypoint.sh) starts `influxd`, runs
`influxdb-apply`, and waits for `influxd` to exit.
```
$ docker run --name influxdb --detach --publish 8086:8086 influxdb-with-apply
```

View the container logs which capture stdout and stderr from `entrypoint.sh`.  Press CTRL-C to stop
waiting for more logs.
```
$ docker logs --follow influxdb 2>&1
#!/bin/sh -ev
influxd &
/influxdb-apply /influxdb-apply.yaml https://localhost:8086/
2020-03-19T00:49:00Z INFO root Reading /influxdb-apply.yaml
2020-03-19T00:49:00Z INFO root Using url https://localhost:8086
2020-03-19T00:49:00Z INFO root Waiting for https://localhost:8086/ping
2020-03-19T00:49:00Z INFO root   HTTPSConnectionPool(host='localhost', port=8086): Max retries exceeded with url: /ping (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7f0cf0573150>: Failed to establish a new connection: [Errno 111] Connection refused',))
ts=2020-03-19T00:49:04.029430Z lvl=info msg="InfluxDB starting" log_id=0Ld4507G000 version=1.7.10 branch=1.7 commit=f46f63d4e2d9684a2dd716594ab609ccd32f0a5b
ts=2020-03-19T00:49:04.029482Z lvl=info msg="Go runtime" log_id=0Ld4507G000 version=go1.12.6 maxprocs=4
ts=2020-03-19T00:49:04.139311Z lvl=info msg="Using data dir" log_id=0Ld4507G000 service=store path=/var/lib/influxdb/data
ts=2020-03-19T00:49:04.139496Z lvl=info msg="Compaction settings" log_id=0Ld4507G000 service=store max_concurrent_compactions=2 throughput_bytes_per_second=50331648 throughput_bytes_per_second_burst=50331648
ts=2020-03-19T00:49:04.139574Z lvl=info msg="Open store (start)" log_id=0Ld4507G000 service=store trace_id=0Ld450Yl000 op_name=tsdb_open op_event=start
ts=2020-03-19T00:49:04.139782Z lvl=info msg="Open store (end)" log_id=0Ld4507G000 service=store trace_id=0Ld450Yl000 op_name=tsdb_open op_event=end op_elapsed=0.210ms
ts=2020-03-19T00:49:04.139854Z lvl=info msg="Opened service" log_id=0Ld4507G000 service=subscriber
ts=2020-03-19T00:49:04.139887Z lvl=info msg="Starting monitor service" log_id=0Ld4507G000 service=monitor
ts=2020-03-19T00:49:04.139914Z lvl=info msg="Registered diagnostics client" log_id=0Ld4507G000 service=monitor name=build
ts=2020-03-19T00:49:04.139983Z lvl=info msg="Registered diagnostics client" log_id=0Ld4507G000 service=monitor name=runtime
ts=2020-03-19T00:49:04.140018Z lvl=info msg="Registered diagnostics client" log_id=0Ld4507G000 service=monitor name=network
ts=2020-03-19T00:49:04.140147Z lvl=info msg="Registered diagnostics client" log_id=0Ld4507G000 service=monitor name=system
ts=2020-03-19T00:49:04.140210Z lvl=info msg="Starting precreation service" log_id=0Ld4507G000 service=shard-precreation check_interval=10m advance_period=30m
ts=2020-03-19T00:49:04.140261Z lvl=info msg="Starting snapshot service" log_id=0Ld4507G000 service=snapshot
ts=2020-03-19T00:49:04.140353Z lvl=info msg="Starting continuous query service" log_id=0Ld4507G000 service=continuous_querier
ts=2020-03-19T00:49:04.140440Z lvl=info msg="Storing statistics" log_id=0Ld4507G000 service=monitor db_instance=_internal db_rp=monitor interval=10s
ts=2020-03-19T00:49:04.140440Z lvl=info msg="Starting HTTP service" log_id=0Ld4507G000 service=httpd authentication=true
ts=2020-03-19T00:49:04.140701Z lvl=info msg="opened HTTP access log" log_id=0Ld4507G000 service=httpd path=stderr
ts=2020-03-19T00:49:04.141374Z lvl=info msg="Listening on HTTP" log_id=0Ld4507G000 service=httpd addr=[::]:8086 https=true
ts=2020-03-19T00:49:04.141491Z lvl=info msg="Starting retention policy enforcement service" log_id=0Ld4507G000 service=retention check_interval=30m
ts=2020-03-19T00:49:04.141988Z lvl=info msg="Sending usage statistics to usage.influxdata.com" log_id=0Ld4507G000
ts=2020-03-19T00:49:04.142092Z lvl=info msg="Listening for signals" log_id=0Ld4507G000
[httpd] 127.0.0.1 - - [19/Mar/2020:00:49:05 +0000] "GET /ping HTTP/1.1" 204 0 "-" "python-requests/2.23.0" 6f066a13-697b-11ea-8001-0242ac110002 128
2020-03-19T00:49:05Z INFO root   204 No Content: 
2020-03-19T00:49:05Z INFO root CREATE USER "admin" WITH PASSWORD '...' WITH ALL PRIVILEGES
ts=2020-03-19T00:49:05.292781Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="CREATE USER admin WITH PASSWORD [REDACTED] WITH ALL PRIVILEGES"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=CREATE+USER+%22admin%22+WITH+PASSWORD+%5BREDACTED%5D+WITH+ALL+PRIVILEGES HTTP/1.1" 200 57 "-" "python-requests/2.23.0" 6f0830ee-697b-11ea-8002-0242ac110002 72175
2020-03-19T00:49:05Z INFO root SHOW USERS
ts=2020-03-19T00:49:05.441091Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="SHOW USERS"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=SHOW+USERS HTTP/1.1" 200 105 "-" "python-requests/2.23.0" 6f1493d5-697b-11ea-8003-0242ac110002 69320
2020-03-19T00:49:05Z INFO root   result_row(user=u'admin', admin=True)
2020-03-19T00:49:05Z INFO root Target users:
2020-03-19T00:49:05Z INFO root   User{admin pass=... grant_all_privileges=true}
2020-03-19T00:49:05Z INFO root   User{telegraf pass=...}
2020-03-19T00:49:05Z INFO root   User{grafana pass=...}
2020-03-19T00:49:05Z INFO root   User{user2}
2020-03-19T00:49:05Z INFO root SET PASSWORD FOR "admin" = '...'
ts=2020-03-19T00:49:05.456340Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="SET PASSWORD FOR admin = [REDACTED]"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=SET+PASSWORD+FOR+%22admin%22+%3D+%5BREDACTED%5D HTTP/1.1" 200 57 "-" "python-requests/2.23.0" 6f213073-697b-11ea-8004-0242ac110002 69792
2020-03-19T00:49:05Z INFO root CREATE USER "telegraf" WITH PASSWORD '...'
ts=2020-03-19T00:49:05.601692Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="CREATE USER telegraf WITH PASSWORD [REDACTED]"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=CREATE+USER+%22telegraf%22+WITH+PASSWORD+%5BREDACTED%5D HTTP/1.1" 200 57 "-" "python-requests/2.23.0" 6f2d56fc-697b-11ea-8005-0242ac110002 135064
2020-03-19T00:49:05Z INFO root CREATE USER "grafana" WITH PASSWORD '...'
ts=2020-03-19T00:49:05.680012Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="CREATE USER grafana WITH PASSWORD [REDACTED]"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=CREATE+USER+%22grafana%22+WITH+PASSWORD+%5BREDACTED%5D HTTP/1.1" 200 57 "-" "python-requests/2.23.0" 6f435008-697b-11ea-8006-0242ac110002 70691
2020-03-19T00:49:05Z INFO root CREATE USER "user2" WITH PASSWORD '<random password>'
ts=2020-03-19T00:49:05.760026Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="CREATE USER user2 WITH PASSWORD [REDACTED]"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=CREATE+USER+%22user2%22+WITH+PASSWORD+%5BREDACTED%5D HTTP/1.1" 200 57 "-" "python-requests/2.23.0" 6f4f7eb2-697b-11ea-8007-0242ac110002 71734
2020-03-19T00:49:05Z INFO root SHOW DATABASES
ts=2020-03-19T00:49:05.840672Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="SHOW DATABASES"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=SHOW+DATABASES HTTP/1.1" 200 94 "-" "python-requests/2.23.0" 6f5bd0b4-697b-11ea-8008-0242ac110002 645
2020-03-19T00:49:05Z INFO root Existing databases: 
2020-03-19T00:49:05Z INFO root Target databases: _internal db1
2020-03-19T00:49:05Z INFO root CREATE DATABASE "_internal" WITH DURATION 14d
ts=2020-03-19T00:49:05.851275Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="CREATE DATABASE _internal WITH DURATION 336h0m0s"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=CREATE+DATABASE+%22_internal%22+WITH+DURATION+14d HTTP/1.1" 200 57 "-" "python-requests/2.23.0" 6f5d6f3e-697b-11ea-8009-0242ac110002 2870
2020-03-19T00:49:05Z INFO root CREATE DATABASE "db1" WITH DURATION 14d
ts=2020-03-19T00:49:05.862359Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="CREATE DATABASE db1 WITH DURATION 336h0m0s"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=CREATE+DATABASE+%22db1%22+WITH+DURATION+14d HTTP/1.1" 200 57 "-" "python-requests/2.23.0" 6f5f2276-697b-11ea-800a-0242ac110002 3901
2020-03-19T00:49:05Z INFO root SHOW GRANTS FOR "admin"
ts=2020-03-19T00:49:05.876869Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="SHOW GRANTS FOR admin"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=SHOW+GRANTS+FOR+%22admin%22 HTTP/1.1" 200 96 "-" "python-requests/2.23.0" 6f615935-697b-11ea-800b-0242ac110002 742
2020-03-19T00:49:05Z INFO root User admin read privileges: existing= target=
2020-03-19T00:49:05Z INFO root User admin write privileges: existing= target=
2020-03-19T00:49:05Z INFO root SHOW GRANTS FOR "telegraf"
ts=2020-03-19T00:49:05.887422Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="SHOW GRANTS FOR telegraf"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=SHOW+GRANTS+FOR+%22telegraf%22 HTTP/1.1" 200 96 "-" "python-requests/2.23.0" 6f62f712-697b-11ea-800c-0242ac110002 352
2020-03-19T00:49:05Z INFO root User telegraf read privileges: existing= target=
2020-03-19T00:49:05Z INFO root User telegraf write privileges: existing= target=db1
2020-03-19T00:49:05Z INFO root GRANT WRITE ON "db1" TO "telegraf"
ts=2020-03-19T00:49:05.898376Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="GRANT WRITE ON db1 TO telegraf"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=GRANT+WRITE+ON+%22db1%22+TO+%22telegraf%22 HTTP/1.1" 200 57 "-" "python-requests/2.23.0" 6f64a237-697b-11ea-800d-0242ac110002 3521
2020-03-19T00:49:05Z INFO root SHOW GRANTS FOR "grafana"
ts=2020-03-19T00:49:05.910875Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="SHOW GRANTS FOR grafana"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=SHOW+GRANTS+FOR+%22grafana%22 HTTP/1.1" 200 96 "-" "python-requests/2.23.0" 6f66857a-697b-11ea-800e-0242ac110002 748
2020-03-19T00:49:05Z INFO root User grafana read privileges: existing= target=db1
2020-03-19T00:49:05Z INFO root User grafana write privileges: existing= target=
2020-03-19T00:49:05Z INFO root GRANT READ ON "db1" TO "grafana"
ts=2020-03-19T00:49:05.920946Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="GRANT READ ON db1 TO grafana"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=GRANT+READ+ON+%22db1%22+TO+%22grafana%22 HTTP/1.1" 200 57 "-" "python-requests/2.23.0" 6f680f0a-697b-11ea-800f-0242ac110002 3755
2020-03-19T00:49:05Z INFO root SHOW GRANTS FOR "user2"
ts=2020-03-19T00:49:05.933338Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="SHOW GRANTS FOR user2"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=SHOW+GRANTS+FOR+%22user2%22 HTTP/1.1" 200 96 "-" "python-requests/2.23.0" 6f69f3ba-697b-11ea-8010-0242ac110002 745
2020-03-19T00:49:05Z INFO root User user2 read privileges: existing= target=
2020-03-19T00:49:05Z INFO root User user2 write privileges: existing= target=db1
2020-03-19T00:49:05Z INFO root GRANT WRITE ON "db1" TO "user2"
ts=2020-03-19T00:49:05.943701Z lvl=info msg="Executing query" log_id=0Ld4507G000 service=query query="GRANT WRITE ON db1 TO user2"
[httpd] 127.0.0.1 - admin [19/Mar/2020:00:49:05 +0000] "POST /query?q=GRANT+WRITE+ON+%22db1%22+TO+%22user2%22 HTTP/1.1" 200 57 "-" "python-requests/2.23.0" 6f6b8703-697b-11ea-8011-0242ac110002 2542
2020-03-19T00:49:05Z INFO root Done.
wait
ts=2020-03-19T00:49:19.971461Z lvl=info msg="failed to store statistics" log_id=0Ld4507G000 service=monitor error="retention policy not found: monitor"
ts=2020-03-19T00:49:29.970243Z lvl=info msg="failed to store statistics" log_id=0Ld4507G000 service=monitor error="retention policy not found: monitor"
ts=2020-03-19T00:49:39.935942Z lvl=info msg="failed to store statistics" log_id=0Ld4507G000 service=monitor error="retention policy not found: monitor"
ts=2020-03-19T00:49:49.936455Z lvl=info msg="failed to store statistics" log_id=0Ld4507G000 service=monitor error="retention policy not found: monitor"
ts=2020-03-19T00:49:59.935330Z lvl=info msg="failed to store statistics" log_id=0Ld4507G000 service=monitor error="retention policy not found: monitor"
ts=2020-03-19T00:50:09.902239Z lvl=info msg="failed to store statistics" log_id=0Ld4507G000 service=monitor error="retention policy not found: monitor"
ts=2020-03-19T00:50:19.901172Z lvl=info msg="failed to store statistics" log_id=0Ld4507G000 service=monitor error="retention policy not found: monitor"
^C
```

Use the configured credentials to write and read the configured database:
```
$ curl --cacert openssl/ca_cert.pem --include https://localhost:8086/ping
HTTP/1.1 204 No Content
Content-Type: application/json
Request-Id: ea9c21e2-6970-11ea-8012-0242ac110002
X-Influxdb-Build: OSS
X-Influxdb-Version: 1.7.10
X-Request-Id: ea9c21e2-6970-11ea-8012-0242ac110002
Date: Wed, 18 Mar 2020 23:33:48 GMT

$ for n in $(seq 1 5); do
curl --cacert openssl/ca_cert.pem --user telegraf:pass-telegraf  --request POST \
  'https://localhost:8086/write?db=db1' \
  --data-binary "metric1,host=host1,tag1=val1 value=$n $(date '+%s')000000000";
sleep 1;
done
$ curl --cacert openssl/ca_cert.pem --user grafana:pass-grafana \
 'https://localhost:8086/query?pretty=true&db=db1' \
 --data-urlencode "q=SELECT \"value\" FROM \"metric1\" WHERE \"host\" = 'host1' ORDER BY time DESC LIMIT 3"
{
    "results": [
        {
            "statement_id": 0,
            "series": [
                {
                    "name": "metric1",
                    "columns": [
                        "time",
                        "value"
                    ],
                    "values": [
                        [
                            "2020-03-19T00:08:25Z",
                            5
                        ],
                        [
                            "2020-03-19T00:08:24Z",
                            4
                        ],
                        [
                            "2020-03-19T00:08:23Z",
                            3
                        ]
                    ]
                }
            ]
        }
    ]
}
```

Stoo influxd and clean up:
```
$ docker container rm --force --volumes influxdb
```
