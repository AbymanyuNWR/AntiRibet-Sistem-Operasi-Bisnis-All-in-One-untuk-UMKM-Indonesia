#!/bin/bash
set -e

echo "====================================="
echo "  Deploying AntiRibet to Production  "
echo "====================================="

echo "1. Pulling latest images & Building containers..."
docker-compose down
docker-compose build
docker-compose up -d

echo "2. Installing Composer dependencies..."
docker-compose exec -T app composer install --optimize-autoloader --no-dev

echo "3. Caching configuration & routes..."
docker-compose exec -T app php artisan config:cache
docker-compose exec -T app php artisan route:cache
docker-compose exec -T app php artisan view:cache

echo "4. Running Database Migrations..."
docker-compose exec -T app php artisan migrate --force

echo "5. Restarting Queues (Worker & Reverb)..."
docker-compose restart queue-worker
# Reverb can be run as a supervisor process inside the container or a separate service,
# For simplicity, we assume Reverb runs as another service if needed in the future.

echo "====================================="
echo "  Deployment Completed Successfully  "
echo "====================================="
