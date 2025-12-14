@echo off
@REM chcp 65001

call :log "=== НАЧАЛО УСТАНОВКИ ==="
echo ========================================
echo    Deployment test-dbo-system
echo ========================================
echo.
call :log "Checking installing Docker"
echo [1/4] Checking installing Docker...
docker --version
if errorlevel 1 (
    call :log "ERROR: Необходимо установить Docker Desktop"
    echo ERROR: Download Docker Desktop
    echo Link on download Docker Desktop: https://docker.com/products/docker-desktop
    pause
    exit /b 1
) else (
    call :log "Docker установлен. Переходим к следующему шагу."
    echo Docker install.
)
call :log "Развертывание в Kubernetes test-dbo-system."
echo [2/4] Deployment Kubernetes test-dbo-system...
set NAMESPACE=test-dbo-system
call :log "create namespace test-dbo-system"
echo create namespace test-dbo-system...
kubectl create namespace %NAMESPACE% --dry-run=client -o yaml | kubectl apply -f -

call :applyResource "Payment DB" k8s/databases/payment-postgres/
call :applyResource "Balance DB" k8s/databases/balance-postgres/
call :applyResource "Notification DB" k8s/databases/notification-postgres/
call :applyResource "Zookeeper" k8s/message-brokers/zookeeper/
echo  Wait start databases and zookeeper...
kubectl wait --for=condition=ready --timeout=300s pod -l "app in (payment-postgres,balance-postgres,notification-postgres,zookeeper)"  -n %NAMESPACE%
kubectl create serviceaccount prometheus-sa -n %NAMESPACE%
call :applyResource "Prometheus" k8s/monitoring/prometheus/
echo apply node-exporter
kubectl apply -f k8s/monitoring/node-exporter/ -n kube-system
call :applyResource "Grafana"  "-k" "k8s/monitoring/grafana/"
call :applyResource "Redis" k8s/caches/redis/
call :applyResource "Kafka" k8s/message-brokers/kafka/

echo  Wait start databases and zookeeper...
kubectl wait --for=condition=ready --timeout=300s pod -l "app in (kafka,grafana,prometheus,node-exporter)"  -n %NAMESPACE%

@REM timeout /t 15 /nobreak

echo Deploy Java-services ...

call :applyResource "Payment Service" k8s/services/payment-service
call :applyResource "Balance Service" k8s/services/balance-service
call :applyResource "Notification Service" k8s/services/notification-service

echo [4/4] Wait start Java-services...
kubectl wait --for=condition=ready --timeout=300s pod -l "app in (payment-service,balance-service,notification-service)" -n %NAMESPACE%


@REM timeout /t 50 /nobreak
kubectl get pods -n %NAMESPACE%

echo Open links on browser
timeout /t 5 /nobreak


echo  Swagger UI Payment API (payment-service)
echo  http://localhost:30081/swagger-ui/index.html
start "" "http://localhost:30081/swagger-ui/index.html"
timeout /t 1 /nobreak >nul

echo  Swagger UI Balance API (balance-service)
echo  http://localhost:30082/swagger-ui/index.html
start "" "http://localhost:30082/swagger-ui/index.html"
timeout /t 1 /nobreak >nul

echo  Swagger UI Notification API (notification-service)
echo  http://localhost:30083/swagger-ui/index.html
start "" "http://localhost:30083/swagger-ui/index.html"
timeout /t 1 /nobreak >nul

echo  Prometheus (metrics)
echo  http://localhost:30090
start "" "http://localhost:30090"
timeout /t 1 /nobreak >nul

echo  Grafana (monitoring)
echo  http://localhost:30300
start "" "http://localhost:30300"
timeout /t 1 /nobreak >nul

echo .
echo Grafana  login:admin password:admin
echo Change password can skip
echo.
echo Press any key to exit...
pause >nul
exit /


:log
echo [%date% %time%] %~1 >> install.log
exit /b

:applyResource
if "%~2"=="-k" (
    kubectl apply -k "%~3" -n %NAMESPACE%
) else (
    kubectl apply -f "%~2" -n %NAMESPACE%
)
if errorlevel 1 (
    echo Warning: %~1
    call :log "Warning:" %~1
) else (
    echo  %~1 Done
    call :log %~1 "Done"
)
exit /b


