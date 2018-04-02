#!/bin/bash

IP=$1
if [[ -z "$IP" ]]; then
  echo "Usage: ./init.sh <host IP>"
  exit 1
fi

if [[ -d certs ]]; then
  echo "certs dir already exists. Please remove to re-generate certificates"
  exit 1
fi

mkdir certs
docker run --rm -v "$PWD/generate.sh:/opt/scripts/generate.sh" -v "$PWD/certs:/certs" --workdir=/certs --entrypoint=/opt/scripts/generate.sh wurstmeister/kafka "$1"

