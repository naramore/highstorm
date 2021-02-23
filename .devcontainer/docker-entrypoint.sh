#!/usr/bin/env bash
set -e

sudo chown root:docker /var/run/docker.sock
sudo chmod 775 /var/run/docker.sock

exec "$@"
