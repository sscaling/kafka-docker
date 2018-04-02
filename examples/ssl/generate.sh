#!/bin/bash -e

# IP should be that of the host-machine - i.e. 192.168.x.x
IP=$1

# Need SSL to generate CA
apk add --update openssl

# Generate a CA for the current host
CA_DN="/C=US/ST=California/L=Cupertino/CN=$1"
openssl req -new -x509 -keyout ca-key -out ca-cert -days 365 -subj "$CA_DN" -passout pass:capass

# Add CA to clients truststore (This is needed by client to connect to broker)
keytool -keystore client.truststore.jks -alias CARoot -import -file ca-cert -storepass storepass -noprompt


# Generate key pair for broker
CERT_DN="cn=$IP, ou=GenericOU, o=GenericO, c=US"
keytool -keystore broker.keystore.jks -alias localhost -validity 364 -genkey -keyalg RSA -storepass storepass -keypass keypass -dname "$CERT_DN"

# Generate a CSR then Sign the certs with the CA
keytool -keystore broker.keystore.jks -alias localhost -certreq -file cert-file -storepass storepass -keypass keypass
openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days 365 -CAcreateserial -passin pass:capass

# Import it into the broker keystore
keytool -keystore broker.keystore.jks -alias CARoot -import -file ca-cert -storepass storepass -noprompt
keytool -keystore broker.keystore.jks -alias localhost -import -file cert-signed -keypass keypass -storepass storepass

