#!/bin/bash -e

testReadWrite() {
	echo 'foo,bar' | kafkacat -b "$BROKER_LIST" -P -D, -t readwrite
	#kafkacat -b $(HOST_IP=1.2.3.4 ../broker-list.sh) -C -e -t readwrite
	kafkacat -b "$BROKER_LIST" -C -e -t readwrite
	return 0
}

testReadWrite
