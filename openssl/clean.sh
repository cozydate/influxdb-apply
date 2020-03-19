#!/bin/sh -ev
cd "$(dirname "$0")"
# Clean up files from previous run
rm -f db db.attr db.old
touch db
echo 01 >nextserial
rm -f ca_key.pem csr.pem nextserial.old new_certs/*.pem
