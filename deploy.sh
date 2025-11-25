#!/bin/bash

echo "Deploy инфраструктуры..."


echo "apply payment-postgres..."
kubectl apply -f k8s/databases/payment-postgres/

echo "apply balance-postgres..."
kubectl apply -f k8s/databases/balance-postgres/

echo "apply notification-postgres..."
kubectl apply -f k8s/databases/notification-postgres/


echo "apply zookeeper..."
kubectl apply -f k8s/message-brokers/zookeeper/
echo "apply kafka..."
kubectl apply -f k8s/message-brokers/kafka/

echo "apply Redis..."
kubectl apply -f k8s/caches/redis/

echo " Ожидание запуска Базы данных..."
sleep 15

echo " Deploy Java-приложениий ..."

echo "apply payment-service..."
kubectl apply -f k8s/services/payment-service


echo "apply balance-service..."
kubectl apply -f k8s/services/balance-service

echo "apply notification-service..."
kubectl apply -f k8s/services/notification-service

echo "Готово!"
echo " Проверка статусов..."
kubectl get pods