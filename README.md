# K8s 3-Tier Application

## Description
A simple 3-tier web application that demonstrates core Kubernetes concepts including Pods, Services, Deployments, ConfigMaps, Secrets, Persistent Storage, and Ingress.

**Architecture:**
- **Frontend**: Web interface (Nginx)
- **Backend**: REST API (Flask)
- **Database**: Data storage (PostgreSQL)

## Architecture Diagram
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  FRONTEND   │────│   BACKEND   │────│  DATABASE   │
│  (Nginx)    │    │   (Flask)   │    │(PostgreSQL) │
│  Port: 80   │    │  Port: 8080 │    │ Port: 5432  │
└─────────────┘    └─────────────┘    └─────────────┘
      │                    │                    │
      └────────────────────┼────────────────────┘
                           │
                    ┌─────────────┐
                    │   INGRESS   │
                    │  Controller │
                    └─────────────┘
```

## How to Install and Run

### Requirements
- Minikube (https://minikube.sigs.k8s.io/docs/start/)
- kubectl (https://kubernetes.io/docs/tasks/tools/)
- Docker (https://docs.docker.com/desktop/)

### Quick Start
```bash
make run
```
This will set up the cluster and deploy the application, then automatically open your browser to http://localhost:8000

### Manual Installation
1. **Set up the cluster:**
   ```bash
   make setup
   ```

2. **Deploy the application:**
   ```bash
   make deploy
   ```

3. **Or do both in one step:**
   ```bash
   make run
   ```

4. **Access the application:**
   - The application should automatically open at: http://localhost:8000

### Available Make Targets
```bash
make help        # Show all available commands
make setup       # Set up Kubernetes cluster  
make deploy      # Deploy the application (on subconsequent runs)
make run         # Setup cluster and deploy (recommended for first time)
make test        # Run comprehensive application tests
make clean       # Clean up all resources
```

## Project Structure
```
k8s-3tier-app/ 
├── Makefile          
├── README.md 
├── app-code/ (App Location)
│   ├── backend.py
│   ├── frontend.html
│   ├── Dockerfile.backend
│   ├── Dockerfile.frontend
│   ├── nginx.conf
│   └── requirements.txt
├── frontend/ 
│   ├── deployment.yaml 
│   └── service.yaml 
├── backend/ 
│   ├── deployment.yaml 
│   ├── service.yaml 
│   └── configmap.yaml 
├── database/ 
│   ├── statefulset.yaml 
│   ├── service.yaml 
│   ├── pvc.yaml 
│   └── secret.yaml 
├── ingress/ 
│   └── ingress.yaml
└── scripts/
    ├── install.sh
    ├── deploy.sh
    ├── test.sh
    └── cleanup.sh
```