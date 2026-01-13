#!/bin/bash

# Exits in case of error
set -e


# Cleans up any existing minikube cluster
# minikube delete || true

# Starts minikube engine
minikube start

# Ensure minikube is running
minikube status

# Enable ingress
minikube addons enable ingress

# Enable local registry
minikube addons enable registry