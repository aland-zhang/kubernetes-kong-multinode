#!/bin/bash
export DC=$1
kubectl --namespace=$1  create -f kong.yml

