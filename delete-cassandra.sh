#!/bin/bash

#kubectl delete svc cassandra-peers
kubectl --namespace=$1 delete svc cassandra-lb
kubectl --namespace=$1 delete svc cassandra
kubectl --namespace=$1 delete petset cassandra
kubectl --namespace=$1 delete pod cassandra-0
kubectl --namespace=$1 delete pod cassandra-1
kubectl --namespace=$1 delete pod cassandra-2
