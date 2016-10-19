#!/bin/bash

kubectl delete pod redis-master
kubectl delete svc redis
kubectl delete svc redis-sentinel
kubectl delete rc redis
kubectl delete rc redis-sentinel
kubectl delete po redis-0
kubectl delete po redis-1
kubectl delete po redis-2

