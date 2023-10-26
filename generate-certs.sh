#!/usr/bin/env bash

# Generate self-signed certificates for testing Aerospike with TLS enabled.

PREFIX='example'
PASSWORD='example'
ORG='Aerospike, Inc.'
VALID_DAYS=30
CERT_DIR="certs"
AEROSPIKE_DIR="aerospike/etc"

# create subdirectory to store certs
echo "Creating '${CERT_DIR}' directory"
mkdir -p $CERT_DIR

# create CA cert
echo "Creating CA certificate"
openssl req -new -x509 -days ${VALID_DAYS} -extensions v3_ca -passout pass:"$PASSWORD" -keyout ${CERT_DIR}/${PREFIX}.ca.key -out ${CERT_DIR}/${PREFIX}.ca.crt -subj "/CN=${PREFIX}.ca/O=$ORG/C=US"

# create ECDSA certs
CERTS=( "${PREFIX}.client" "${PREFIX}.server" )
for CERT in "${CERTS[@]}"
do
    echo "Creating ${CERT} ECDSA certificate"
    openssl ecparam -genkey -out ${CERT_DIR}/ecparam.pem -name prime256v1
    openssl genpkey -paramfile ${CERT_DIR}/ecparam.pem -out ${CERT_DIR}/${CERT}.key
    openssl req -new -key ${CERT_DIR}/${CERT}.key -out ${CERT_DIR}/${CERT}.csr -subj "/CN=${CERT}/O=$ORG/C=US"
    openssl x509 -req -days ${VALID_DAYS} -passin pass:"$PASSWORD" -in ${CERT_DIR}/${CERT}.csr -CA ${CERT_DIR}/${PREFIX}.ca.crt -CAkey ${CERT_DIR}/${PREFIX}.ca.key -CAcreateserial -out ${CERT_DIR}/${CERT}.crt
    rm ${CERT_DIR}/ecparam.pem ${CERT_DIR}/${CERT}.csr ${CERT_DIR}/${PREFIX}.ca.srl
done

echo "Copying server certificate to aerospike server config directory"
mkdir -p aerospike/etc/certs/
mkdir -p aerospike/etc/private/
cp ${CERT_DIR}/${PREFIX}.ca.crt ${AEROSPIKE_DIR}/certs/
cp ${CERT_DIR}/${PREFIX}.server.crt ${AEROSPIKE_DIR}/certs/
cp ${CERT_DIR}/${PREFIX}.server.key ${AEROSPIKE_DIR}/private/

echo "---"
tree ${CERT_DIR} ${AEROSPIKE_DIR}/certs/ ${AEROSPIKE_DIR}/private/


# Add certificates to TrustStore/KeyStore for testing Aerospike with TLS enabled
# in JVM-based applications.

PREFIX='example'
CERTS=( "${PREFIX}.client" "${PREFIX}.server" )
CERT_DIR="certs"
TRUSTSTORE_DIR="etc/pki/certs"
TRUSTSTORE_PASSWORD="changeit"
KEYSTORE_DIR="etc/pki/private"
KEYSTORE_PASSWORD="changeit"

# create subdirectory to store certs
echo "Creating TrustStore directory: '${TRUSTSTORE_DIR}'"
mkdir -p $TRUSTSTORE_DIR
echo "Creating KeyStore directory: '${KEYSTORE_DIR}'"
mkdir -p $KEYSTORE_DIR

# create jks variant of CA certificate TrustStore
echo "Creating $TRUSTSTORE_DIR/${PREFIX}.ca.jks"
cp $CERT_DIR/${PREFIX}.ca.crt $TRUSTSTORE_DIR
rm -f $TRUSTSTORE_DIR/${PREFIX}.ca.jks
keytool -importcert -noprompt -storetype jks -alias ${PREFIX}.ca -keystore $TRUSTSTORE_DIR/${PREFIX}.ca.jks -file $CERT_DIR/${PREFIX}.ca.crt -storepass $TRUSTSTORE_PASSWORD

# create pkcs12 variant of client certificate key pair KeyStore
echo "Creating $KEYSTORE_DIR/${PREFIX}.client.p12"
cat $CERT_DIR/${PREFIX}.ca.crt $CERT_DIR/${PREFIX}.client.crt $CERT_DIR/${PREFIX}.client.key > $KEYSTORE_DIR/${PREFIX}.client.chain.crt
openssl pkcs12 -export -in $KEYSTORE_DIR/${PREFIX}.client.chain.crt -out $KEYSTORE_DIR/${PREFIX}.client.chain.p12 -password pass:"$KEYSTORE_PASSWORD" -name ${PREFIX}.client -noiter -nomaciter

# print for confirmation
echo "---"
echo "$TRUSTSTORE_DIR/${PREFIX}.ca.jks"
keytool -list -keystore $TRUSTSTORE_DIR/${PREFIX}.ca.p12 -storepass $TRUSTSTORE_PASSWORD

echo "---"
echo "$KEYSTORE_DIR/${PREFIX}.client.chain.p12"
keytool -list -keystore $KEYSTORE_DIR/${PREFIX}.client.chain.p12 -storepass $KEYSTORE_PASSWORD

echo "---"
tree $TRUSTSTORE_DIR $KEYSTORE_DIR

