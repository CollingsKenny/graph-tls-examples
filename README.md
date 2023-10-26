Graph TLS Examples
================================================================================

See [this project](https://github.com/aerospike-examples/aerospike-tls-examples) for basic examples of connecting to Aerospike without using Aerospike Graph.



### Prerequisites

* A *Feature Key File* (`features.conf`) for 
  [Aerospike Enterprise](https://www.aerospike.com/products/product-matrix/)
* [Docker](https://www.docker.com/) (verify with: `docker -v`)
* [OpenSSL](https://www.openssl.org/) (verify with: `openssl version`)
* If you are on a Mac, install `tree` with `brew install tree`

* Java Development Kit (JDK) (verify with: `javac -version`)
* Maven (verify with: `mvn -version`)
    * Maven will install the [Aerospike Java Client](https://www.aerospike.com/docs/client/java/)


Quick Start
--------------------------------------------------------------------------------

### 1 - Generate Certificates

Execute `generate-certs.sh` to generate example self-signed TLS certificates:

```
$ ./generate-certs.sh
```
* If you are getting the error “Error Loading extension section v3_ca” using macOS, add the following to your `/etc/ssl/openssl.cnf`
```
[ v3_ca ]
basicConstraints = critical,CA:TRUE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always
```

Output:
```
Creating 'certs' directory
Creating CA certificate
Generating a RSA private key
...................................................+++++
.....................+++++
writing new private key to 'certs/example.ca.key'
-----
Creating example.client ECDSA certificate
Signature ok
subject=CN = example.client, O = "Aerospike, Inc.", C = US
Getting CA Private Key
Creating example.server ECDSA certificate
Signature ok
subject=CN = example.server, O = "Aerospike, Inc.", C = US
Getting CA Private Key
Copying server certificate to aerospike server config directory
'certs/example.ca.crt' -> 'aerospike/etc/certs/example.ca.crt'
'certs/example.server.crt' -> 'aerospike/etc/certs/example.server.crt'
'certs/example.server.key' -> 'aerospike/etc/private/example.server.key'
---
certs
├── example.ca.crt
├── example.ca.key
├── example.client.crt
├── example.client.key
├── example.server.crt
└── example.server.key
aerospike/etc/certs/
├── example.ca.crt
└── example.server.crt
aerospike/etc/private/
└── example.server.key

Creating TrustStore directory: 'etc/pki/certs'
Creating KeyStore directory: 'etc/pki/private'
Creating etc/pki/certs/example.ca.jks
Certificate was added to keystore
Creating etc/pki/private/example.client.p12
---
etc/pki/certs/example.ca.jks
keytool error: java.lang.Exception: Keystore file does not exist: etc/pki/certs/example.ca.p12
---
etc/pki/private/example.client.chain.p12
Keystore type: PKCS12
Keystore provider: SUN

Your keystore contains 1 entry

example.client, Apr 5, 2020, PrivateKeyEntry, 
Certificate fingerprint (SHA1): A3:63:D6:B0:3B:E9:7E:78:81:46:5F:D6:53:93:5D:57:27:1B:FE:6D
---
etc/pki/certs
├── example.ca.crt
└── example.ca.jks
etc/pki/private
├── example.client.chain.crt
└── example.client.chain.p12
```

### 2 - Install Feature Key File

Copy your `features.conf` file (provided by your Aerospike representative) to 
`aerospike/etc/features.conf`.

### 3a - Start Graph and Aerospike Server (Standard TLS)

Run Docker Compose configured for standard TLS:

```
docker compose -f compose-stls.yaml up
```

Output:
```
...
graph-tls-examples-graph-1          | [INFO] o.a.t.g.s.GremlinServer$1 - Gremlin Server configured with worker thread pool of 1, gremlin pool of 16 and boss thread pool of 1.
graph-tls-examples-graph-1          | [INFO] o.a.t.g.s.GremlinServer$1 - Channel started at port 8182.
graph-tls-examples-graph-1          | [INFO] c.a.f.i.AerospikeConnection - Initializing AerospikeConnection.
```

### 3b - Start Graph and Aerospike Server (Mutual TLS)

Run Docker Compose configured for mutual TLS (mTLS):

```
docker compose -f compose-mtls.yaml up
``` 

Output:
```
...
graph-tls-examples-graph-1          | [INFO] o.a.t.g.s.GremlinServer$1 - Gremlin Server configured with worker thread pool of 1, gremlin pool of 16 and boss thread pool of 1.
graph-tls-examples-graph-1          | [INFO] o.a.t.g.s.GremlinServer$1 - Channel started at port 8182.
graph-tls-examples-graph-1          | [INFO] c.a.f.i.AerospikeConnection - Initializing AerospikeConnection.
```

### 4 - (Optional) Clean up

Stop and remove docker containers:

```
docker compose -f compose-stls.yaml down
```

or

```
docker compose -f compose-mtls.yaml down
```
