Graph TLS Examples
================================================================================

See [this project](https://github.com/aerospike-examples/aerospike-tls-examples) for basic examples of connecting to Aerospike without using Aerospike Graph.



### Prerequisites

* A *Feature Key File* (`features.conf`) for 
  [Aerospike Enterprise](https://www.aerospike.com/products/product-matrix/)
* [Docker](https://www.docker.com/) (verify with: `docker -v`)
* [OpenSSL](https://www.openssl.org/) (verify with: `openssl version`)
* If you are on a Mac, install `tree` with `brew install tree`

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
```

### 2 - Install Feature Key File

Copy your `features.conf` file (provided by your Aerospike representative) to 
`aerospike/etc/features.conf`.

### 3a - Start Graph and Aerospike Server (Standard TLS)

Run Docker Compose configured for standard TLS:

```
$ docker compose -f compose-std.yaml up
```


### 3b - Start Graph and Aerospike Server  (Mutual TLS)

Run Docker Compose configured for mutual TLS (mTLS):

```
$ docker compose -f compose-mut.yaml up
``` 
