#!/bin/bash

# Script pour configurer le monitoring avec Prometheus et Grafana
# Usage: ./setup-monitoring.sh

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}== Configuration du monitoring avec Prometheus et Grafana ==${NC}"

mkdir -p monitoring/grafana/provisioning/datasources
mkdir -p monitoring/grafana/provisioning/dashboards
mkdir -p monitoring/grafana/dashboards

echo -e "${YELLOW}Copie des fichiers de configuration...${NC}"
cp prometheus.yml monitoring/
touch monitoring/grafana/provisioning/datasources/datasource.yml
touch monitoring/grafana/provisioning/dashboards/dashboard.yml

cat > monitoring/grafana/provisioning/datasources/datasource.yml << EOF
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
EOF

cat > monitoring/grafana/provisioning/dashboards/dashboard.yml << EOF
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    options:
      path: /var/lib/grafana/dashboards
EOF

echo -e "${YELLOW}Téléchargement des tableaux de bord...${NC}"
curl -s https://grafana.com/api/dashboards/1860/revisions/27/download > monitoring/grafana/dashboards/node-exporter.json
curl -s https://grafana.com/api/dashboards/893/revisions/10/download > monitoring/grafana/dashboards/docker-containers.json

echo -e "${GREEN}Configuration terminée${NC}"
echo -e "${BLUE}Pour démarrer le monitoring:${NC} cd monitoring && docker-compose up -d"
echo -e "${BLUE}Grafana sera accessible sur:${NC} http://localhost:3000 (admin/admin)"
echo -e "${BLUE}Prometheus sera accessible sur:${NC} http://localhost:9090"