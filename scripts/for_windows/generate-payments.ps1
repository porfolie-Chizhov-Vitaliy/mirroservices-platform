

$paymentUrl = "http://localhost:30081/api/payments"
$fromAccounts = @("40817810099910004328", "40817810099910004324", "40817810099910004323", "40817810099910004321", "40817810099910004327")
$toAccounts = @("40817810099910004328", "40817810099910004324", "40817810099910004323", "40817810099910004321", "40817810099910004327", "42601810500000010101")

Write-Host "Создание 100 тестовых платежей..." -ForegroundColor Green

for ($i = 1; $i -le 100; $i++) {
    $fromAccount = $fromAccounts | Get-Random
    $toAccount = $toAccounts | Get-Random
    $amount = Get-Random -Minimum 100 -Maximum 50000

    $payload = @{
        amount = $amount
        fromAccount = $fromAccount
        toAccount = $toAccount
        currency = "RUB"
        description = "Test payment #$i"
    } | ConvertTo-Json

    Write-Host " Payment $i`: $amount RUB from $fromAccount to $toAccount" -ForegroundColor Cyan

    try {
        $response = Invoke-WebRequest -Uri $paymentUrl -Method POST -Headers @{"Content-Type"="application/json"} -Body $payload -UseBasicParsing
                Write-Host "✅ Success" -ForegroundColor Green
                Write-Host "   HTTP Code: $($response.StatusCode)" -ForegroundColor Gray
                Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorMessage = $_.Exception.Message
        Write-Host "❌ Error: $statusCode" -ForegroundColor Red
        Write-Host "   Message: $errorMessage" -ForegroundColor Red

        # Если есть тело ошибки
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $errorBody = $reader.ReadToEnd()
        if ($errorBody) {
            Write-Host "   Body: $errorBody" -ForegroundColor Red
        }

    }

    Start-Sleep -Milliseconds 300
}

Write-Host "`n 50 платежей создано! Проверяйте дашборды Grafana." -ForegroundColor Green

Write-Host "`nНажмите любую клавишу для выхода..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')