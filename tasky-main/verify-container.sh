#!/bin/bash

# Script to verify wizexercise.txt exists in the running container
# This demonstrates how to validate the file requirement for the Wiz exercise

echo "Verifying wizexercise.txt file in container..."

# Get the pod name
POD_NAME=$(kubectl get pods -l app=tasky-app -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD_NAME" ]; then
    echo "No tasky-app pods found!"
    exit 1
fi

echo "Found pod: $POD_NAME"

# Check if wizexercise.txt exists in the container
if kubectl exec $POD_NAME -- test -f /app/wizexercise.txt; then
    echo "✅ wizexercise.txt file exists in container"
    echo "File contents:"
    kubectl exec $POD_NAME -- cat /app/wizexercise.txt
else
    echo "❌ wizexercise.txt file NOT found in container"
    exit 1
fi

echo "✅ Container verification complete!" 