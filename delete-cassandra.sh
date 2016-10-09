#!/bin/bash

#kubectl delete svc cassandra-peers
kubectl delete svc cassandra-lb
kubectl delete svc cassandra
kubectl delete petset cassandra
kubectl delete pod cassandra-0
kubectl delete pod cassandra-1
kubectl delete pod cassandra-2
