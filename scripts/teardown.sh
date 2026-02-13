#!/bin/bash
# Stop and remove all containers, networks, and volumes

echo "Tearing down the CDC prototype stack..."
docker compose down -v
echo "All containers, networks, and volumes removed."
