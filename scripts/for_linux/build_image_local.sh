#!/bin/bash
echo "Сборка локальных докер образов"

echo "build payment-service:latest ...."
cd ../../payment-service/
docker build -t payment-service:latest .
cd ..
echo "build balance-service:latest ...."  
cd balance-service/
docker build -t balance-service:latest .
cd ..
echo "build notification-service ...."
cd notification-service/
docker build -t notification-service:latest .

echo "Все образы собраны"
