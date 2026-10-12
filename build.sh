#!/bin/sh
docker build . -f ./Dockerfile.client -t sdwan-client:latest
docker build . -f ./Dockerfile.switch -t sdwan-ovs:latest


containerlab redeploy
