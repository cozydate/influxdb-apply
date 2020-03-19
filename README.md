# influxdb-apply

This is a Python 2 program that reads an `influxdb-apply.yaml` file and updates InfluxDB users and
databases to match what's in the file.  It deletes all users and databases not in the config file.

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

A good way to make passwords:

```$ python -c 'import random; r = random.SystemRandom(); print "".join([r.choice("123456789CDFGHJKLMNPQRTVWXZ") for n in range(12)])'```

Check out [`Dockerfile`](blob/master/Dockerfile) and [`init-influxdb.sh`](blob/master/init-influxdb.sh) to see how this works.

Example usage:
```
$ docker build -t influxdb-with-apply .
Sending build context to Docker daemon  111.6kB
Step 1/10 : FROM influxdb@sha256:213f19092ddac0e75e1709ce6f687c29428ecf7fd57f24bf2043e662299d7552
 ---> 11022dc8112f
Step 2/10 : RUN apk add --no-cache python2 py-pip && pip install jsonschema==3.2.0 PyYAML==5.2 requests==2.23.0
 ---> Using cache
 ---> 6a5bd3e817ea
Step 3/10 : ADD openssl/ca_cert.pem /etc/influxdb/ca_cert.pem
 ---> Using cache
 ---> a9e3bf86b850
Step 4/10 : ADD openssl/cert.pem /etc/influxdb/cert.pem
 ---> Using cache
 ---> 5aa85f807c39
Step 5/10 : ADD openssl/key.pem /etc/influxdb/key.pem
 ---> Using cache
 ---> 17932cefb713
Step 6/10 : ADD influxdb.conf /etc/influxdb/influxdb.conf
 ---> Using cache
 ---> a27a6e369a00
Step 7/10 : ADD influxdb-apply /influxdb-apply
 ---> Using cache
 ---> de8f77b7c1d0
Step 8/10 : ADD influxdb-apply.yaml /influxdb-apply.yaml
 ---> Using cache
 ---> 561865431819
Step 9/10 : ENV REQUESTS_CA_BUNDLE=/etc/influxdb/ca_cert.pem
 ---> Using cache
 ---> 3a8b76ef9b92
Step 10/10 : ADD init-influxdb.sh /init-influxdb.sh
 ---> Using cache
 ---> ec9745706da6
Successfully built ec9745706da6
Successfully tagged influxdb-with-apply:latest
$ docker run --name influxdb --interactive --tty --rm --publish 8086:8086 influxdb-with-apply
#!/bin/sh -ev
influxd &
/influxdb-apply /influxdb-apply.yaml https://localhost:8086/
2020-03-18T23:32:52Z INFO root Reading /influxdb-apply.yaml
2020-03-18T23:32:52Z INFO root Using url https://localhost:8086
2020-03-18T23:32:52Z INFO root Waiting for https://localhost:8086/ping
2020-03-18T23:32:52Z INFO root   HTTPSConnectionPool(host='localhost', port=8086): Max retries exceeded with url: /ping (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7f5ce051d150>: Failed to establish a new connection: [Errno 111] Connection refused',))

 8888888           .d888 888                   8888888b.  888888b.
   888            d88P"  888                   888  "Y88b 888  "88b
   888            888    888                   888    888 888  .88P
   888   88888b.  888888 888 888  888 888  888 888    888 8888888K.
   888   888 "88b 888    888 888  888  Y8bd8P' 888    888 888  "Y88b
   888   888  888 888    888 888  888   X88K   888    888 888    888
   888   888  888 888    888 Y88b 888 .d8""8b. 888  .d88P 888   d88P
 8888888 888  888 888    888  "Y88888 888  888 8888888P"  8888888P"

2020-03-18T23:32:55.722564Z	info	InfluxDB starting	{"log_id": "0Lc~jBAW000", "version": "1.7.10", "branch": "1.7", "commit": "f46f63d4e2d9684a2dd716594ab609ccd32f0a5b"}
2020-03-18T23:32:55.722673Z	info	Go runtime	{"log_id": "0Lc~jBAW000", "version": "go1.12.6", "maxprocs": 4}
2020-03-18T23:32:55.832910Z	info	Using data dir	{"log_id": "0Lc~jBAW000", "service": "store", "path": "/var/lib/influxdb/data"}
2020-03-18T23:32:55.833226Z	info	Compaction settings	{"log_id": "0Lc~jBAW000", "service": "store", "max_concurrent_compactions": 2, "throughput_bytes_per_second": 50331648, "throughput_bytes_per_second_burst": 50331648}
2020-03-18T23:32:55.833396Z	info	Open store (start)	{"log_id": "0Lc~jBAW000", "service": "store", "trace_id": "0Lc~jBbG000", "op_name": "tsdb_open", "op_event": "start"}
2020-03-18T23:32:55.833764Z	info	Open store (end)	{"log_id": "0Lc~jBAW000", "service": "store", "trace_id": "0Lc~jBbG000", "op_name": "tsdb_open", "op_event": "end", "op_elapsed": "0.253ms"}
2020-03-18T23:32:55.834016Z	info	Opened service	{"log_id": "0Lc~jBAW000", "service": "subscriber"}
2020-03-18T23:32:55.834112Z	info	Starting monitor service	{"log_id": "0Lc~jBAW000", "service": "monitor"}
2020-03-18T23:32:55.834193Z	info	Registered diagnostics client	{"log_id": "0Lc~jBAW000", "service": "monitor", "name": "build"}
2020-03-18T23:32:55.834303Z	info	Registered diagnostics client	{"log_id": "0Lc~jBAW000", "service": "monitor", "name": "runtime"}
2020-03-18T23:32:55.834392Z	info	Registered diagnostics client	{"log_id": "0Lc~jBAW000", "service": "monitor", "name": "network"}
2020-03-18T23:32:55.834575Z	info	Registered diagnostics client	{"log_id": "0Lc~jBAW000", "service": "monitor", "name": "system"}
2020-03-18T23:32:55.834829Z	info	Starting precreation service	{"log_id": "0Lc~jBAW000", "service": "shard-precreation", "check_interval": "10m", "advance_period": "30m"}
2020-03-18T23:32:55.834923Z	info	Starting snapshot service	{"log_id": "0Lc~jBAW000", "service": "snapshot"}
2020-03-18T23:32:55.835020Z	info	Starting continuous query service	{"log_id": "0Lc~jBAW000", "service": "continuous_querier"}
2020-03-18T23:32:55.835186Z	info	Starting HTTP service	{"log_id": "0Lc~jBAW000", "service": "httpd", "authentication": true}
2020-03-18T23:32:55.835415Z	info	opened HTTP access log	{"log_id": "0Lc~jBAW000", "service": "httpd", "path": "stderr"}
2020-03-18T23:32:55.835586Z	info	Storing statistics	{"log_id": "0Lc~jBAW000", "service": "monitor", "db_instance": "_internal", "db_rp": "monitor", "interval": "10s"}
2020-03-18T23:32:55.836463Z	info	Listening on HTTP	{"log_id": "0Lc~jBAW000", "service": "httpd", "addr": "[::]:8086", "https": true}
2020-03-18T23:32:55.836752Z	info	Starting retention policy enforcement service	{"log_id": "0Lc~jBAW000", "service": "retention", "check_interval": "30m"}
2020-03-18T23:32:55.837830Z	info	Sending usage statistics to usage.influxdata.com	{"log_id": "0Lc~jBAW000"}
2020-03-18T23:32:55.838153Z	info	Listening for signals	{"log_id": "0Lc~jBAW000"}
[httpd] 127.0.0.1 - - [18/Mar/2020:23:32:57 +0000] "GET /ping HTTP/1.1" 204 0 "-" "python-requests/2.23.0" cc25c191-6970-11ea-8001-0242ac110002 99
2020-03-18T23:32:57Z INFO root   204 No Content: 
2020-03-18T23:32:57Z INFO root CREATE USER "admin" WITH PASSWORD '...' WITH ALL PRIVILEGES
2020-03-18T23:32:57.059724Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "CREATE USER admin WITH PASSWORD [REDACTED] WITH ALL PRIVILEGES"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=CREATE+USER+%22admin%22+WITH+PASSWORD+%5BREDACTED%5D+WITH+ALL+PRIVILEGES HTTP/1.1" 200 57 "-" "python-requests/2.23.0" cc272ada-6970-11ea-8002-0242ac110002 73069
2020-03-18T23:32:57Z INFO root SHOW USERS
2020-03-18T23:32:57.209514Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "SHOW USERS"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=SHOW+USERS HTTP/1.1" 200 105 "-" "python-requests/2.23.0" cc33c879-6970-11ea-8003-0242ac110002 67833
2020-03-18T23:32:57Z INFO root   result_row(user=u'admin', admin=True)
2020-03-18T23:32:57Z INFO root Target users:
2020-03-18T23:32:57Z INFO root   User{admin pass=... grant_all_privileges=true}
2020-03-18T23:32:57Z INFO root   User{telegraf pass=...}
2020-03-18T23:32:57Z INFO root   User{grafana pass=...}
2020-03-18T23:32:57Z INFO root   User{user2}
2020-03-18T23:32:57Z INFO root SET PASSWORD FOR "admin" = '...'
2020-03-18T23:32:57.229950Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "SET PASSWORD FOR admin = [REDACTED]"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=SET+PASSWORD+FOR+%22admin%22+%3D+%5BREDACTED%5D HTTP/1.1" 200 57 "-" "python-requests/2.23.0" cc4124ef-6970-11ea-8004-0242ac110002 70709
2020-03-18T23:32:57Z INFO root CREATE USER "telegraf" WITH PASSWORD '...'
2020-03-18T23:32:57.378591Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "CREATE USER telegraf WITH PASSWORD [REDACTED]"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=CREATE+USER+%22telegraf%22+WITH+PASSWORD+%5BREDACTED%5D HTTP/1.1" 200 57 "-" "python-requests/2.23.0" cc4d7c60-6970-11ea-8005-0242ac110002 138967
2020-03-18T23:32:57Z INFO root CREATE USER "grafana" WITH PASSWORD '...'
2020-03-18T23:32:57.467384Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "CREATE USER grafana WITH PASSWORD [REDACTED]"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=CREATE+USER+%22grafana%22+WITH+PASSWORD+%5BREDACTED%5D HTTP/1.1" 200 57 "-" "python-requests/2.23.0" cc6560f5-6970-11ea-8006-0242ac110002 70435
2020-03-18T23:32:57Z INFO root CREATE USER "user2" WITH PASSWORD '<random password>'
2020-03-18T23:32:57.553067Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "CREATE USER user2 WITH PASSWORD [REDACTED]"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=CREATE+USER+%22user2%22+WITH+PASSWORD+%5BREDACTED%5D HTTP/1.1" 200 57 "-" "python-requests/2.23.0" cc727856-6970-11ea-8007-0242ac110002 70322
2020-03-18T23:32:57Z INFO root SHOW DATABASES
2020-03-18T23:32:57.633544Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "SHOW DATABASES"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=SHOW+DATABASES HTTP/1.1" 200 94 "-" "python-requests/2.23.0" cc7ebd57-6970-11ea-8008-0242ac110002 908
2020-03-18T23:32:57Z INFO root Existing databases: 
2020-03-18T23:32:57Z INFO root Target databases: _internal db1
2020-03-18T23:32:57Z INFO root CREATE DATABASE "_internal" WITH DURATION 14d
2020-03-18T23:32:57.645378Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "CREATE DATABASE _internal WITH DURATION 336h0m0s"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=CREATE+DATABASE+%22_internal%22+WITH+DURATION+14d HTTP/1.1" 200 57 "-" "python-requests/2.23.0" cc8081bd-6970-11ea-8009-0242ac110002 3087
2020-03-18T23:32:57Z INFO root CREATE DATABASE "db1" WITH DURATION 14d
2020-03-18T23:32:57.657850Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "CREATE DATABASE db1 WITH DURATION 336h0m0s"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=CREATE+DATABASE+%22db1%22+WITH+DURATION+14d HTTP/1.1" 200 57 "-" "python-requests/2.23.0" cc826fc8-6970-11ea-800a-0242ac110002 3912
2020-03-18T23:32:57Z INFO root SHOW GRANTS FOR "admin"
2020-03-18T23:32:57.673569Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "SHOW GRANTS FOR admin"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=SHOW+GRANTS+FOR+%22admin%22 HTTP/1.1" 200 96 "-" "python-requests/2.23.0" cc84d8ce-6970-11ea-800b-0242ac110002 3559
2020-03-18T23:32:57Z INFO root User admin read privileges: existing= target=
2020-03-18T23:32:57Z INFO root User admin write privileges: existing= target=
2020-03-18T23:32:57Z INFO root SHOW GRANTS FOR "telegraf"
2020-03-18T23:32:57.687571Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "SHOW GRANTS FOR telegraf"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=SHOW+GRANTS+FOR+%22telegraf%22 HTTP/1.1" 200 96 "-" "python-requests/2.23.0" cc86fd1b-6970-11ea-800c-0242ac110002 805
2020-03-18T23:32:57Z INFO root User telegraf read privileges: existing= target=
2020-03-18T23:32:57Z INFO root User telegraf write privileges: existing= target=db1
2020-03-18T23:32:57Z INFO root GRANT WRITE ON "db1" TO "telegraf"
2020-03-18T23:32:57.700874Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "GRANT WRITE ON db1 TO telegraf"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=GRANT+WRITE+ON+%22db1%22+TO+%22telegraf%22 HTTP/1.1" 200 57 "-" "python-requests/2.23.0" cc88f127-6970-11ea-800d-0242ac110002 4754
2020-03-18T23:32:57Z INFO root SHOW GRANTS FOR "grafana"
2020-03-18T23:32:57.716559Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "SHOW GRANTS FOR grafana"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=SHOW+GRANTS+FOR+%22grafana%22 HTTP/1.1" 200 96 "-" "python-requests/2.23.0" cc8b6a09-6970-11ea-800e-0242ac110002 637
2020-03-18T23:32:57Z INFO root User grafana read privileges: existing= target=db1
2020-03-18T23:32:57Z INFO root User grafana write privileges: existing= target=
2020-03-18T23:32:57Z INFO root GRANT READ ON "db1" TO "grafana"
2020-03-18T23:32:57.729154Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "GRANT READ ON db1 TO grafana"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=GRANT+READ+ON+%22db1%22+TO+%22grafana%22 HTTP/1.1" 200 57 "-" "python-requests/2.23.0" cc8d467c-6970-11ea-800f-0242ac110002 2780
2020-03-18T23:32:57Z INFO root SHOW GRANTS FOR "user2"
2020-03-18T23:32:57.741133Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "SHOW GRANTS FOR user2"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=SHOW+GRANTS+FOR+%22user2%22 HTTP/1.1" 200 96 "-" "python-requests/2.23.0" cc8f2488-6970-11ea-8010-0242ac110002 1055
2020-03-18T23:32:57Z INFO root User user2 read privileges: existing= target=
2020-03-18T23:32:57Z INFO root User user2 write privileges: existing= target=db1
2020-03-18T23:32:57Z INFO root GRANT WRITE ON "db1" TO "user2"
2020-03-18T23:32:57.756080Z	info	Executing query	{"log_id": "0Lc~jBAW000", "service": "query", "query": "GRANT WRITE ON db1 TO user2"}
[httpd] 127.0.0.1 - admin [18/Mar/2020:23:32:57 +0000] "POST /query?q=GRANT+WRITE+ON+%22db1%22+TO+%22user2%22 HTTP/1.1" 200 57 "-" "python-requests/2.23.0" cc91651c-6970-11ea-8011-0242ac110002 4557
2020-03-18T23:32:57Z INFO root Done.
wait
```

While that's running, open another console and test:
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

To shut down influxdb, switch back to the first console and press CTRL-C.
