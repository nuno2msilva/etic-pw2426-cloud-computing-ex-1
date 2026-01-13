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

# Check services
if kubectl get services | grep -q frontend-service; then
    echo "✅ Services exist"
else
    echo "❌ Services missing"
    exit 1
fi

echo "Tests passed!"