#!/bin/bash

echo "Создание 50 тестовых платежей..."

PAYMENT_URL="http://localhost:30081/api/payments"
CONTENT_TYPE="Content-Type: application/json"





# Массивы реальных банковских счетов
FROM_ACCOUNTS=("40817810099910004328" "40817810099910004324" "40817810099910004323"
                "40817810099910004321" "40817810099910004327")

TO_ACCOUNTS=("40817810099910004328" "40817810099910004324" "40817810099910004323"
              "40817810099910004321" "40817810099910004327" "42601810500000010101")

for i in {1..100}; do
    # Случайные счета из массивов
    FROM_INDEX=$((RANDOM % ${#FROM_ACCOUNTS[@]}))
    TO_INDEX=$((RANDOM % ${#TO_ACCOUNTS[@]}))

    FROM_ACCOUNT=${FROM_ACCOUNTS[$FROM_INDEX]}
    TO_ACCOUNT=${TO_ACCOUNTS[$TO_INDEX]}
    AMOUNT=$((RANDOM % 50000 + 100))  # 100-50000 руб

    PAYLOAD=$(cat <<EOF
{
    "amount": $AMOUNT,
    "fromAccount": "$FROM_ACCOUNT",
    "toAccount": "$TO_ACCOUNT",
    "currency": "RUB",
    "description": "Test payment #$i"
}
EOF
)

    echo " Payment $i: $AMOUNT RUB from $FROM_ACCOUNT to $TO_ACCOUNT"

    # Отправляем платеж
    response=$(curl -X POST "$PAYMENT_URL" \
            -H "$CONTENT_TYPE" \
            -d "$PAYLOAD" \
            -s -w "\n%{http_code}")

    json_response=$(echo "$response" | head -n -1)
    http_code=$(echo "$response" | tail -n1)

    echo "Response: $json_response"
    echo "HTTP Code: $http_code"
    echo ""

    sleep 0.3
done

echo " 50 payments generated! Check Grafana dashboards."