#!/bin/bash

kubectl --namespace=$1 delete svc kong-app
kubectl --namespace=$1 delete rc kong-app
