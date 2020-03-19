# https://hub.docker.com/_/influxdb/
# influxdb:1.7.10-alpine
FROM influxdb@sha256:213f19092ddac0e75e1709ce6f687c29428ecf7fd57f24bf2043e662299d7552
RUN apk add --no-cache python2 py-pip && pip install jsonschema==3.2.0 PyYAML==5.2 requests==2.23.0

ADD openssl/ca_cert.pem /etc/influxdb/ca_cert.pem
ADD openssl/cert.pem /etc/influxdb/cert.pem
ADD openssl/key.pem /etc/influxdb/key.pem
ADD influxdb.conf /etc/influxdb/influxdb.conf

ADD influxdb-apply /influxdb-apply
ADD influxdb-apply.yaml /influxdb-apply.yaml
# Make influxdb-apply accept the certificate.
ENV REQUESTS_CA_BUNDLE=/etc/influxdb/ca_cert.pem

# Don't use buggy /init-influxdb.sh script.
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT /entrypoint.sh
