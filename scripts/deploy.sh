#!/bin/bash

set -e

# Ensure kubectl is pointing to minikube
kubectl config use-context minikube

# Wait for API server to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Verify cluster is ready
kubectl get nodes

# Build images using minikube docker
eval $(minikube docker-env)
cd app-code
docker build -t k8s-frontend:latest -f Dockerfile.frontend .
docker build -t k8s-backend:latest -f Dockerfile.backend .
cd ..

# Wait for nginx ingress controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

# Wait for admission webhook service to be available
echo "HEY! This is not stuck and you are not forgotten! Please standby!"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=60s

# Ensure the webhook service is reachable
until kubectl get service -n ingress-nginx ingress-nginx-controller-admission >/dev/null 2>&1; do
  echo "Waiting for admission webhook service..."
  sleep 5
done

# Additional wait for webhook to be fully functional
sleep 15

# Deploy resources in order
kubectl apply -f database/ 
kubectl apply -f backend/ 
kubectl apply -f frontend/ 

# Apply ingress after everything else is ready
kubectl apply -f ingress/ 

# Wait for pods to be ready
kubectl wait --for=condition=Ready pods -l app=frontend --timeout=120s
kubectl wait --for=condition=Ready pods -l app=backend --timeout=120s
kubectl wait --for=condition=Ready pods -l app=postgres --timeout=120s

# Initialize database table
kubectl exec deployment/backend-deployment -- python3 -c "
import psycopg2, os, time
for attempt in range(10):
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST', 'postgres-service'),
            port=os.getenv('DB_PORT', '5432'),
            database=os.getenv('DB_NAME', 'k8s_app'),
            user=os.getenv('DB_USER', 'postgres'),
            password=os.getenv('DB_PASSWORD', 'secretpassword')
        )
        with conn.cursor() as cursor:
            cursor.execute('CREATE TABLE IF NOT EXISTS users (id SERIAL PRIMARY KEY, name VARCHAR(255) NOT NULL, message TEXT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);')
        conn.commit()
        conn.close()
        print('Database initialized successfully!')
        break
    except Exception as e:
        print(f'Attempt {attempt+1}: {e}')
        time.sleep(2)
else:
    print('Failed to initialize database after 10 attempts')
"

# Set up port forwarding to localhost:8000
kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8000:80 &
PORT_FORWARD_PID=$!

# Open browser automatically
if [ -n "$BROWSER" ]; then
    "$BROWSER" http://localhost:8000
else
    xdg-open http://localhost:8000
fi