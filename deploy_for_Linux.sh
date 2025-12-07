#!/bin/bash
NAMESPACE=${1:-test-dbo-system}
echo "Deployling to namespace... $NAMESPACE"

echo "create namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "apply payment-postgres..."
kubectl apply -f k8s/databases/payment-postgres/ -n $NAMESPACE

echo "apply balance-postgres..."
kubectl apply -f k8s/databases/balance-postgres/ -n $NAMESPACE

echo "apply notification-postgres..."
kubectl apply -f k8s/databases/notification-postgres/ -n $NAMESPACE
echo "apply node-exporter..."
kubectl apply -f k8s/monitoring/node-exporter/ -n kube-system
echo "apply zookeeper..."
kubectl apply -f k8s/message-brokers/zookeeper/ -n $NAMESPACE
echo "apply kafka..."
kubectl apply -f k8s/message-brokers/kafka/ -n $NAMESPACE

echo "apply Prometheus..."
kubectl create serviceaccount prometheus-sa -n test-dbo-system
kubectl apply -f k8s/monitoring/prometheus/ -n $NAMESPACE

echo "apply Grafana  with Kustomize..."
kubectl apply -k k8s/monitoring/grafana/ -n $NAMESPACE
#kubectl apply -f k8s/monitoring/grafana/ -n $NAMESPACE
#echo "delete default configmap grafana-dashboards"
#kubectl delete configmap grafana-dashboards -n $NAMESPACE

#echo "create configmap and add dashboards from k8s/monitoring/grafana/provisioning/dashboards/"
#kubectl create configmap grafana-dashboards \
#  --from-file=k8s/monitoring/grafana/provisioning/dashboards/ \
#  -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "apply Redis..."
kubectl apply -f k8s/caches/redis/ -n $NAMESPACE

echo " Ожидание запуска Базы данных..."
sleep 15

echo " Deploy Java-приложениий ..."

echo "apply payment-service..."
kubectl apply -f k8s/services/payment-service -n $NAMESPACE


echo "apply balance-service..."
kubectl apply -f k8s/services/balance-service -n $NAMESPACE

echo "apply notification-service..."
kubectl apply -f k8s/services/notification-service -n $NAMESPACE

echo "Готово!"
echo " Проверка статусов..."
sleep 30
kubectl get pods -n $NAMESPACE