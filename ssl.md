SSL
===

Reference: [http://kafka.apache.org/documentation.html#security](http://kafka.apache.org/documentation.html#security)

$(hostname) should be IP of host

```
# Generate key
CERT_DN="cn=$(hostname), ou=GenericOU, o=GenericO, c=US"
keytool -keystore server.keystore.jks -alias localhost -validity 364 -genkey -keyalg RSA -storepass storepass -keypass keypass -dname "$CERT_DN"

# Not required[-ext SAN=IP:192.168.128.156]

# Validate
keytool -list -v -keystore server.keystore.jks

# Generate CA
apk add --update openssl
CA_DN="/C=US/ST=California/L=Cupertino/CN=$(hostname)"
openssl req -new -x509 -keyout ca-key -out ca-cert -days 365 -subj "$CA_DN" -passout pass:capass

# Add CA to clients truststore
keytool -keystore client.truststore.jks -alias CARoot -import -file ca-cert -storepass storepass -noprompt

# Add CA to server truststore if client certs are enabed (`ssl.client.auth`). Then distribute to brokers
keytool -keystore server.truststore.jks -alias CARoot -import -file ca-cert -storepass storepass -noprompt

# Generate a CSR then Sign the certs with the CA
keytool -keystore server.keystore.jks -alias localhost -certreq -file cert-file -storepass storepass -keypass keypass
openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days 365 -CAcreateserial -passin pass:capass

# Import it into the broker keystore
keytool -keystore server.keystore.jks -alias CARoot -import -file ca-cert -storepass storepass -noprompt
keytool -keystore server.keystore.jks -alias localhost -import -file cert-signed -keypass keypass -storepass storepass [-noprompt ?]
```

**NOTE:** can we use `-storetype=PKCS12` to get rid of errors?

Need to then hook producers/consumers up to use SSL

(Java) `security.protocol`, `ssl.truststore.location` and `ssl.truststore.password`.

TODO:
-----

-	Endpoint verification `ssl.endpoint.identification.algorithm`
-	SAN in gen generation? allow DNS FQDN for verification
-	JCE ? [https://github.com/davidcaste/docker-alpine-java-unlimited-jce/blob/master/generate_dockerfiles.sh](https://github.com/davidcaste/docker-alpine-java-unlimited-jce/blob/master/generate_dockerfiles.sh)
