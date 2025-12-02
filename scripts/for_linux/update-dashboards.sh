#!/bin/bash

echo "🔄 Updating Grafana dashboards..."

# Папка с дашбордами
DASHBOARDS_DIR="k8s/monitoring/grafana/provisioning/dashboards"
NAMESPACE="test-dbo-system"

# Удаляем старый ConfigMap
kubectl delete configmap grafana-dashboards -n $NAMESPACE 2>/dev/null || true

# Создаём новый с дашбордами
kubectl create configmap grafana-dashboards \
  --from-file=$DASHBOARDS_DIR/ \
  -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Перезапускаем Grafana
kubectl rollout restart deployment/grafana -n $NAMESPACE

echo "✅ Dashboards updated! New pod:"
kubectl get pods -l app=grafana -n $NAMESPACE --no-headers | awk '{print $1}'
echo "🌐 Access: http://localhost:30300"