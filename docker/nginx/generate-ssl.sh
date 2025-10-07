#!/bin/sh

CERT_DIR="/etc/ssl/certs"
KEY_DIR="/etc/ssl/private"

mkdir -p "$CERT_DIR" "$KEY_DIR"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY_DIR/nginx.key" \
    -out "$CERT_DIR/nginx.crt" \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

chmod 644 "$CERT_DIR/nginx.crt"
chmod 600 "$KEY_DIR/nginx.key"

echo "SSL certificates generated successfully!"
