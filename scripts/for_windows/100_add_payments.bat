@echo off
chcp 65001 >nul
echo Запуск генератора платежей...
echo.

powershell -ExecutionPolicy Bypass -File generate-payments.ps1

echo.
pause