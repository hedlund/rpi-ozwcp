#!/bin/bash

set -e

docker build -t hedlund/rpi-ozwcp:latest .
docker push hedlund/rpi-ozwcp:latest
