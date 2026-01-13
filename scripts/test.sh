#!/bin/bash

echo "Testing application..."

# Check pods
PODS=$(kubectl get pods --no-headers | grep Running | wc -l)
if [ "$PODS" -ge 3 ]; then
    echo "✅ Pods running: $PODS"
else
    echo "❌ Not enough pods running: $PODS"
    exit 1
fi

# Check all expected services exist
EXPECTED_SERVICES=("frontend-service" "backend-service" "postgres-service")
for service in "${EXPECTED_SERVICES[@]}"; do
    if kubectl get services | grep -q "$service"; then
        echo "✅ Service exists: $service"
    else
        echo "❌ Service missing: $service"
        exit 1
    fi
done

# Check database StatefulSet and PVC
if kubectl get statefulset | grep -q postgres; then
    echo "✅ Database StatefulSet exists"
else
    echo "❌ Database StatefulSet missing"
    exit 1
fi

if kubectl get pvc | grep -q postgres-pvc; then
    echo "✅ Database PVC exists"
else
    echo "❌ Database PVC missing"
    exit 1
fi

# Check secrets and configmaps
if kubectl get secret | grep -q postgres-secret; then
    echo "✅ Database secret exists"
else
    echo "❌ Database secret missing"
    exit 1
fi

if kubectl get configmap | grep -q backend-config; then
    echo "✅ Backend ConfigMap exists"
else
    echo "❌ Backend ConfigMap missing"
    exit 1
fi

# Check ingress
if kubectl get ingress | grep -q k8s-3tier-ingress; then
    echo "✅ Ingress exists"
else
    echo "❌ Ingress missing"
    exit 1
fi

# Health check - try to reach the application
echo "Performing health checks..."
SERVICE_TYPE=$(kubectl get service frontend-service -o jsonpath='{.spec.type}' 2>/dev/null)
if [ "$SERVICE_TYPE" = "NodePort" ]; then
    FRONTEND_PORT=$(kubectl get service frontend-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:$FRONTEND_PORT | grep -q "200\|302"; then
        echo "✅ Frontend is responding"
    else
        echo "⚠️ Frontend not responding (may still be starting up)"
    fi
elif [ "$SERVICE_TYPE" = "ClusterIP" ]; then
    kubectl port-forward service/frontend-service 8080:80 &>/dev/null &
    PF_PID=$!
    sleep 2
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200\|302"; then
        echo "✅ Frontend is responding"
    else
        echo "⚠️ Frontend not responding (may still be starting up)"
    fi
    kill $PF_PID 2>/dev/null
else
    echo "⚠️ Could not determine service type for health check"
fi

# Check if pods are actually ready (not just running)
NOT_READY=$(kubectl get pods --no-headers | grep -v "1/1\|2/2\|3/3" | wc -l)
if [ "$NOT_READY" -eq 0 ]; then
    echo "✅ All pods are ready"
else
    echo "⚠️ Some pods not fully ready: $NOT_READY"
    kubectl get pods --no-headers | grep -v "1/1\|2/2\|3/3"
fi

echo "Tests completed!"