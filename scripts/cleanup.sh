#!/bin/bash

# Deletes all deployed resources
kubectl delete -f ingress/ --ignore-not-found=true
kubectl delete -f frontend/ --ignore-not-found=true  
kubectl delete -f backend/ --ignore-not-found=true
kubectl delete -f database/ --ignore-not-found=true

echo "Deleted all deployed resources. Goodbye!"