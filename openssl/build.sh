#!/bin/sh -ev
cd "$(dirname "$0")"
./clean.sh
# Create CA key and cert
openssl req -newkey rsa:2048 -nodes -keyout ca_key.pem -subj "/OU=ca" -days 731 -sha256 -x509 -out ca_cert.pem
# Create CSR
openssl req -config openssl.cnf -newkey rsa:2048 -nodes -keyout key.pem -days 731 -sha256 -new -out csr.pem
# Create cert
# https://blog.zencoffee.org/2013/04/creating-and-signing-an-ssl-cert-with-alternative-names/#%20signing-a-csr-with-embedded-or-desired-sans
openssl ca -config openssl.cnf -batch -cert ca_cert.pem -keyfile ca_key.pem -in csr.pem -out cert.pem
# Print cert
openssl x509 -in cert.pem -text
# Done.
