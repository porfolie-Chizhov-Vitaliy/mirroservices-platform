#!/bin/bash

echo delete node-exporter
kubectl delete -f k8s/monitoring/node-exporter/ -n kube-system
echo delete namespace test-dbo-system
kubectl delete namespace test-dbo-system