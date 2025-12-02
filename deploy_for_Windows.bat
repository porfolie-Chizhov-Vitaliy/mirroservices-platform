@echo off
chcp 65001
echo ========================================
echo    Начало развертывания test-dbo-system
echo ========================================
echo.

echo [1/3] Checking installing Docker...
docker --version
if errorlevel 1 (
    echo ERROR: Необходимо установить Docker Desktop
    echo Ссылка на установку Docker Desktop: https://docker.com/products/docker-desktop
    pause
    exit /b 1
) else (
    echo Docker установлен. Переходим к следующему шагу.
)

echo [2/3] Развертывание в Kubernetes test-dbo-system...
set NAMESPACE=test-dbo-system

echo create namespace test-dbo-system...
kubectl create namespace %NAMESPACE% --dry-run=client -o yaml | kubectl apply -f -

echo apply payment-postgres...
kubectl apply -f k8s/databases/payment-postgres/ -n %NAMESPACE%

echo apply balance-postgres...
kubectl apply -f k8s/databases/balance-postgres/ -n %NAMESPACE%

echo apply notification-postgres... 
kubectl apply -f k8s/databases/notification-postgres/ -n %NAMESPACE%


echo  apply zookeeper... 
kubectl apply -f k8s/message-brokers/zookeeper/ -n %NAMESPACE%
echo  apply kafka... 
kubectl apply -f k8s/message-brokers/kafka/ -n %NAMESPACE%

echo  apply Prometheus... 
kubectl create serviceaccount prometheus-sa -n test-dbo-system
kubectl apply -f k8s/monitoring/prometheus/ -n %NAMESPACE%

echo  apply Grafana  with Kustomize... 
kubectl apply -k k8s/monitoring/grafana/ -n %NAMESPACE%

echo  apply Redis... 
kubectl apply -f k8s/caches/redis/ -n %NAMESPACE%

echo   Ожидание запуска Базы данных... 
timeout /t 15 /nobreak

echo   Deploy Java-приложениий ... 

echo  apply payment-service... 
kubectl apply -f k8s/services/payment-service -n %NAMESPACE%


echo  apply balance-service... 
kubectl apply -f k8s/services/balance-service -n %NAMESPACE%

echo  apply notification-service... 
kubectl apply -f k8s/services/notification-service -n %NAMESPACE%

echo  Готово! 



echo [3/3] Starting services...
timeout /t 50 /nobreak
kubectl get pods -n %NAMESPACE%

echo Открывает сервисы в браузере
timeout /t 5 /nobreak



set URLs[0]=http://localhost:30081
set URLs[1]=http://localhost:30082
set URLs[2]=http://localhost:30083
set URLs[3]=http://localhost:30090
set URLs[4]=http://localhost:30300

set Desc[0]=Payment API (платежи)
set Desc[1]=Balance API (балансы)
set Desc[2]=Notification API (уведомления)
set Desc[3]=Prometheus (метрики)
set Desc[4]=Grafana (мониторинг)



echo Swagger UI Payment API:  http://localhost:30081/swagger-ui/index.html
echo Swagger UI Balance API:  http://localhost:30082/swagger-ui/index.html
echo Swagger UI Notification API:  http://localhost:30083/swagger-ui/index.html
echo Grafana: http://localhost:30300
echo .
echo Grafana  login:admin password:admin
echo Смену пароля можно пропустить.
echo .
pause