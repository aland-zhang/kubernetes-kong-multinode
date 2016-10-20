#!/bin/bash
kubectl --namespace=$1  create -f cassandra-pet-set.yml

