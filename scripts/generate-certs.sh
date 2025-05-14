#!/bin/bash

# Exit on error
set -e

# Create directories
mkdir -p certs
cd certs

# Generate CA private key and certificate
openssl genrsa -out ca.key 4096
openssl req -new -x509 -days 365 -key ca.key -out ca.crt -subj "/CN=Redis-Vault-CA"

# Generate server private key
openssl genrsa -out server.key 2048

# Generate server CSR
openssl req -new -key server.key -out server.csr -subj "/CN=localhost"

# Sign server certificate with CA
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt

# Generate client private key
openssl genrsa -out client.key 2048

# Generate client CSR
openssl req -new -key client.key -out client.csr -subj "/CN=client"

# Sign client certificate with CA
openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt

# Set proper permissions
chmod 600 *.key
chmod 644 *.crt

# Clean up
rm *.csr *.srl

echo "Certificates generated successfully in the 'certs' directory"
echo "CA Certificate: ca.crt"
echo "Server Certificate: server.crt"
echo "Server Private Key: server.key"
echo "Client Certificate: client.crt"
echo "Client Private Key: client.key" 