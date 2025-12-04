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

call :applyResource "Payment DB" k8s/databases/payment-postgres/
call :applyResource "Balance DB" k8s/databases/balance-postgres/
call :applyResource "Notification DB" k8s/databases/notification-postgres/
call :applyResource "Zookeeper" k8s/message-brokers/zookeeper/
call :applyResource "Kafka" k8s/message-brokers/kafka/
kubectl create serviceaccount prometheus-sa -n %NAMESPACE%
call :applyResource "Prometheus" k8s/monitoring/prometheus/
call :applyResource "Grafana"  "-k" "k8s/monitoring/grafana/"
call :applyResource "Redis" k8s/caches/redis/

echo   Ожидание запуска Базы данных... 
timeout /t 15 /nobreak

echo   Deploy Java-приложениий ... 

call :applyResource "Payment Service" k8s/services/payment-service
call :applyResource "Balance Service" k8s/services/balance-service
call :applyResource "Notification Service" k8s/services/notification-service

echo  Готово! 



echo [3/3] Starting services...
timeout /t 50 /nobreak
kubectl get pods -n %NAMESPACE%

echo Открывает сервисы в браузере
timeout /t 5 /nobreak


echo  Swagger UI Payment API (платежи)
echo  http://localhost:30081/swagger-ui/index.html
start "" "http://localhost:30081/swagger-ui/index.html"
timeout /t 1 /nobreak >nul

echo  Swagger UI Balance API (балансы)
echo  http://localhost:30082/swagger-ui/index.html
start "" "http://localhost:30082/swagger-ui/index.html"
timeout /t 1 /nobreak >nul

echo  Swagger UI Notification API (уведомления)
echo  http://localhost:30083/swagger-ui/index.html
start "" "http://localhost:30083/swagger-ui/index.html"
timeout /t 1 /nobreak >nul

echo  Prometheus (метрики)
echo  http://localhost:30090
start "" "http://localhost:30090"
timeout /t 1 /nobreak >nul

echo  Grafana (мониторинг)
echo  http://localhost:30300
start "" "http://localhost:30300"
timeout /t 1 /nobreak >nul

echo .
echo Grafana  login:admin password:admin
echo Смену пароля можно пропустить.
echo .
echo.
echo Нажмите любую клавишу для выхода...
pause >nul
exit /b

:applyResource
if "%~2"=="-k" (
    kubectl apply -k "%~3" -n %NAMESPACE%
) else (
    kubectl apply -f "%~2" -n %NAMESPACE%
)
if errorlevel 1 (
    echo Предупреждение: %~1
) else (
    echo  %~1 развернут
)
exit /b


